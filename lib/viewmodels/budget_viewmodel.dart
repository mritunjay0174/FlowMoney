import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/enums.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class BudgetWithSpend {
  final Budget budget;
  final double spent;
  final Category? category;

  const BudgetWithSpend({
    required this.budget,
    required this.spent,
    this.category,
  });

  double get percentage =>
      budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;

  bool get isOverBudget => spent > budget.amount;

  bool get nearAlert =>
      percentage >= budget.alertThreshold && !isOverBudget;
}

class BudgetViewModel extends ChangeNotifier {
  final DatabaseService _db;
  final NotificationService _notifications;
  static const _uuid = Uuid();

  BudgetViewModel(this._db, this._notifications);

  List<BudgetWithSpend> _budgets = [];
  List<Category> _categories = [];
  bool _loading = false;
  String? _error;

  List<BudgetWithSpend> get budgets => _budgets;
  List<Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _db.getAllCategories();
      await _refreshBudgets();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshBudgets() async {
    final raw = await _db.getAllBudgets();
    final now = DateTime.now();

    _budgets = await Future.wait(raw.map((b) async {
      final (from, to) = _periodRange(b, now);
      final spent = await _db.getTotalByType(
        TransactionType.expense,
        from: from,
        to: to,
      );

      // Check alert
      final pct = b.amount > 0 ? spent / b.amount : 0.0;
      if (pct >= b.alertThreshold && !b.alertFired) {
        b.alertFired = true;
        await _db.updateBudget(b);
        await _notifications.showBudgetAlert(b.name, pct);
      }

      Category? cat;
      if (b.categoryId != null) {
        try {
          cat = _categories.firstWhere((c) => c.id == b.categoryId);
        } catch (_) {}
      }

      return BudgetWithSpend(budget: b, spent: spent, category: cat);
    }));
    // Note: notifyListeners() is intentionally NOT called here.
    // It will be called by load() in the finally block after _loading = false.
  }

  (DateTime, DateTime) _periodRange(Budget b, DateTime now) {
    switch (b.period) {
      case BudgetPeriod.weekly:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return (DateTime(start.year, start.month, start.day),
            DateTime(start.year, start.month, start.day + 7));
      case BudgetPeriod.monthly:
        return (DateTime(now.year, now.month, 1),
            DateTime(now.year, now.month + 1, 1));
      case BudgetPeriod.yearly:
        return (DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
    }
  }

  Future<void> addBudget({
    required String name,
    required double amount,
    required String currency,
    required BudgetPeriod period,
    String? categoryId,
    double alertThreshold = 0.80,
  }) async {
    final budget = Budget(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      currency: currency,
      period: period,
      startDate: DateTime.now(),
      alertThreshold: alertThreshold,
      categoryId: categoryId,
    );
    await _db.insertBudget(budget);
    await load();
  }

  Future<void> deleteBudget(String id) async {
    await _db.deleteBudget(id);
    _budgets.removeWhere((b) => b.budget.id == id);
    notifyListeners();
  }
}
