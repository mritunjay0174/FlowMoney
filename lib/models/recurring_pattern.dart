import 'dart:convert';
import 'enums.dart';

class RecurringPattern {
  final String id;
  final String name;
  final String? categoryId;
  double typicalAmount;
  final String currency;
  int preferredHour;
  double preferredHourVariance;
  List<int> activeDays;
  int occurrenceCount;
  DateTime? lastOccurrence;
  final PatternSource source;

  RecurringPattern({
    required this.id,
    required this.name,
    this.categoryId,
    required this.typicalAmount,
    required this.currency,
    required this.preferredHour,
    this.preferredHourVariance = 1.0,
    required this.activeDays,
    this.occurrenceCount = 1,
    this.lastOccurrence,
    required this.source,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category_id': categoryId,
        'typical_amount': typicalAmount,
        'currency': currency,
        'preferred_hour': preferredHour,
        'preferred_hour_variance': preferredHourVariance,
        'active_days': jsonEncode(activeDays),
        'occurrence_count': occurrenceCount,
        'last_occurrence': lastOccurrence?.toIso8601String(),
        'source': source.dbValue,
      };

  factory RecurringPattern.fromMap(Map<String, dynamic> map) => RecurringPattern(
        id: map['id'] as String,
        name: map['name'] as String,
        categoryId: map['category_id'] as String?,
        typicalAmount: map['typical_amount'] as double,
        currency: map['currency'] as String,
        preferredHour: map['preferred_hour'] as int,
        preferredHourVariance: map['preferred_hour_variance'] as double,
        activeDays: List<int>.from(
          jsonDecode(map['active_days'] as String) as List,
        ),
        occurrenceCount: map['occurrence_count'] as int,
        lastOccurrence: map['last_occurrence'] != null
            ? DateTime.parse(map['last_occurrence'] as String)
            : null,
        source: PatternSource.fromDb(map['source'] as String),
      );
}
