import 'dart:math';
import '../models/recurring_pattern.dart';
import '../models/transaction.dart';
import '../models/enums.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class SuggestedPattern {
  final RecurringPattern pattern;
  final double score;

  const SuggestedPattern({required this.pattern, required this.score});
}

class SuggestionEngine {
  static const _uuid = Uuid();

  /// Returns top 4 suggestions sorted by composite score, filtered > 0.15
  List<SuggestedPattern> topSuggestions(
    List<RecurringPattern> patterns,
    DateTime now,
  ) {
    final scored = patterns
        .map((p) => SuggestedPattern(
              pattern: p,
              score: _score(p, now),
            ))
        .where((s) => s.score > 0.15)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scored.take(4).toList();
  }

  double _score(RecurringPattern p, DateTime now) {
    final time = _timeProximity(p.preferredHour, now.hour, p.preferredHourVariance);
    final freq = _frequencyScore(p.occurrenceCount);
    final day = _dayOfWeekScore(p.activeDays, now.weekday);
    final recency = _recencyScore(p.lastOccurrence);
    return time * 0.45 + freq * 0.25 + day * 0.20 + recency * 0.10;
  }

  /// Gaussian decay centred on preferredHour
  double _timeProximity(int preferred, int current, double variance) {
    final diff = (preferred - current).abs().toDouble();
    final sigma2 = max(variance, 1.0);
    return exp(-(diff * diff) / (2 * sigma2));
  }

  /// Logarithmic frequency — diminishing returns
  double _frequencyScore(int count) {
    return min(log(count + 1) / log(50), 1.0);
  }

  /// Binary day-of-week match (1=Mon..7=Sun)
  double _dayOfWeekScore(List<int> activeDays, int today) {
    if (activeDays.contains(today)) return 1.0;
    final prev = today == 1 ? 7 : today - 1;
    final next = today == 7 ? 1 : today + 1;
    if (activeDays.contains(prev) || activeDays.contains(next)) return 0.3;
    return 0.0;
  }

  /// Exponential decay, half-life 7 days
  double _recencyScore(DateTime? lastOccurrence) {
    if (lastOccurrence == null) return 0.5;
    final days = DateTime.now().difference(lastOccurrence).inDays.toDouble();
    return exp(-days / 7.0);
  }

  /// Welford online update of preferredHour mean + variance
  void updatePattern(RecurringPattern p, int newHour) {
    final n = p.occurrenceCount + 1;
    final oldMean = p.preferredHour.toDouble();
    final newMean = oldMean + (newHour - oldMean) / n;
    final oldVar = p.preferredHourVariance;
    final newVar = ((n - 2) * oldVar + (newHour - oldMean) * (newHour - newMean)) /
        max(n - 1, 1);
    p.preferredHour = newMean.round();
    p.preferredHourVariance = max(newVar, 0.25);
    p.occurrenceCount = n;
    p.lastOccurrence = DateTime.now();
  }

  /// Auto-discover patterns from transaction notes
  Future<void> discoverPatterns(
    List<Transaction> transactions,
    List<RecurringPattern> existing,
    DatabaseService db,
    String currency,
  ) async {
    // Group by normalised note
    final groups = <String, List<Transaction>>{};
    for (final t in transactions.where((t) => t.note.isNotEmpty)) {
      final key = t.note.trim().toLowerCase();
      groups.putIfAbsent(key, () => []).add(t);
    }

    for (final entry in groups.entries) {
      final txns = entry.value;
      if (txns.length < 3) continue;

      // Check hour std-dev
      final hours = txns.map((t) => t.hourOfDay.toDouble()).toList();
      final mean = hours.reduce((a, b) => a + b) / hours.length;
      final variance =
          hours.map((h) => pow(h - mean, 2)).reduce((a, b) => a + b) /
              hours.length;
      final stdDev = sqrt(variance);
      if (stdDev >= 3.0) continue;

      // Check if pattern already exists
      final alreadyExists = existing
          .any((p) => p.name.toLowerCase() == entry.key);
      if (alreadyExists) continue;

      // Create new learned pattern
      final days = txns.map((t) => t.dayOfWeek).toSet().toList();
      final avgAmount =
          txns.map((t) => t.amount).reduce((a, b) => a + b) / txns.length;

      final pattern = RecurringPattern(
        id: _uuid.v4(),
        name: txns.first.note.trim(),
        typicalAmount: avgAmount,
        currency: currency,
        preferredHour: mean.round(),
        preferredHourVariance: max(variance, 0.25),
        activeDays: days,
        occurrenceCount: txns.length,
        lastOccurrence: txns
            .map((t) => t.date)
            .reduce((a, b) => a.isAfter(b) ? a : b),
        source: PatternSource.learned,
      );

      await db.insertPattern(pattern);
    }
  }
}
