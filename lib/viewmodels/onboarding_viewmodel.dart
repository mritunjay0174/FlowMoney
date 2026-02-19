import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/recurring_pattern.dart';
import '../models/enums.dart';
import '../services/database_service.dart';
import '../services/data_seeder.dart';
import 'app_state.dart';

class OnboardingExpense {
  final String name;
  final String emoji;
  final int defaultHour;
  double amount;
  int hour;
  bool selected;

  OnboardingExpense({
    required this.name,
    required this.emoji,
    required this.defaultHour,
    this.amount = 0.0,
    bool? selected,
  })  : hour = defaultHour,
        selected = selected ?? false;
}

class OnboardingViewModel extends ChangeNotifier {
  static const _uuid = Uuid();

  final DatabaseService _db;
  final AppState _appState;

  OnboardingViewModel(this._db, this._appState);

  int _page = 0;
  String _selectedCurrency = 'USD';
  bool _completing = false;

  int get page => _page;
  String get selectedCurrency => _selectedCurrency;
  bool get completing => _completing;

  final List<OnboardingExpense> presets = [
    OnboardingExpense(name: 'Morning Coffee', emoji: '☕', defaultHour: 8),
    OnboardingExpense(name: 'Lunch', emoji: '🍱', defaultHour: 12),
    OnboardingExpense(name: 'Gym', emoji: '💪', defaultHour: 7),
    OnboardingExpense(name: 'Dinner', emoji: '🍽️', defaultHour: 19),
    OnboardingExpense(name: 'Transport', emoji: '🚌', defaultHour: 8),
    OnboardingExpense(name: 'Groceries', emoji: '🛒', defaultHour: 18),
    OnboardingExpense(name: 'Cinema', emoji: '🎬', defaultHour: 20),
    OnboardingExpense(name: 'Snacks', emoji: '🍿', defaultHour: 15),
  ];

  List<OnboardingExpense> _custom = [];
  List<OnboardingExpense> get custom => _custom;

  List<OnboardingExpense> get selectedExpenses =>
      [...presets, ..._custom].where((e) => e.selected).toList();

  void nextPage() {
    _page++;
    notifyListeners();
  }

  void prevPage() {
    if (_page > 0) _page--;
    notifyListeners();
  }

  void setCurrency(String code) {
    _selectedCurrency = code;
    notifyListeners();
  }

  void togglePreset(int index) {
    presets[index].selected = !presets[index].selected;
    notifyListeners();
  }

  void updatePresetAmount(int index, double amount) {
    presets[index].amount = amount;
    notifyListeners();
  }

  void updatePresetHour(int index, int hour) {
    presets[index].hour = hour;
    notifyListeners();
  }

  void addCustomExpense(String name, String emoji, double amount, int hour) {
    _custom.add(OnboardingExpense(
      name: name,
      emoji: emoji,
      defaultHour: hour,
      amount: amount,
      selected: true,
    ));
    notifyListeners();
  }

  Future<void> complete() async {
    _completing = true;
    notifyListeners();

    // Seed default categories
    await DataSeeder.seedIfNeeded(_db);

    // Create patterns from selected expenses
    for (final expense in selectedExpenses) {
      final pattern = RecurringPattern(
        id: _uuid.v4(),
        name: '${expense.emoji} ${expense.name}',
        typicalAmount: expense.amount,
        currency: _selectedCurrency,
        preferredHour: expense.hour,
        preferredHourVariance: 1.0,
        activeDays: [1, 2, 3, 4, 5], // Mon-Fri default
        occurrenceCount: 1,
        source: PatternSource.onboarding,
      );
      await _db.insertPattern(pattern);
    }

    await _appState.completeOnboarding(currency: _selectedCurrency);
    _completing = false;
    notifyListeners();
  }
}
