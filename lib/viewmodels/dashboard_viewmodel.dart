import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/enums.dart';
import '../services/database_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DatabaseService _db;

  DashboardViewModel(this._db);

  List<Transaction> _recent = [];
  List<Budget> _budgets = [];
  List<Category> _categories = [];
  double _monthIncome = 0;
  double _monthExpense = 0;
  bool _loading = false;
  String? _error;

  List<Transaction> get recent => _recent;
  List<Budget> get budgets => _budgets;
  List<Category> get categories => _categories;
  double get monthIncome => _monthIncome;
  double get monthExpense => _monthExpense;
  double get netBalance => _monthIncome - _monthExpense;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1);

      _recent = await _db.getAllTransactions(limit: 20);
      _categories = await _db.getAllCategories();
      _budgets = await _db.getAllBudgets();
      _monthIncome =
          await _db.getTotalByType(TransactionType.income, from: start, to: end);
      _monthExpense = await _db.getTotalByType(TransactionType.expense,
          from: start, to: end);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Category? categoryFor(String? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Spending percentage per category (for ring chart)
  List<MapEntry<Category, double>> get categorySpending {
    final map = <String, double>{};
    for (final t in _recent.where((t) => t.type == TransactionType.expense)) {
      final key = t.categoryId ?? 'uncategorized';
      map[key] = (map[key] ?? 0) + t.amount;
    }
    final result = <MapEntry<Category, double>>[];
    for (final entry in map.entries) {
      final cat = categoryFor(entry.key);
      if (cat != null) {
        result.add(MapEntry(cat, entry.value));
      }
    }
    result.sort((a, b) => b.value.compareTo(a.value));
    return result.take(5).toList();
  }
}
