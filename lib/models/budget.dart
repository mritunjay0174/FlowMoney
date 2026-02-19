import 'enums.dart';

class Budget {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final BudgetPeriod period;
  final DateTime startDate;
  final double alertThreshold;
  bool alertFired;
  final String? categoryId;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.period,
    required this.startDate,
    this.alertThreshold = 0.80,
    this.alertFired = false,
    this.categoryId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'currency': currency,
        'period': period.dbValue,
        'start_date': startDate.toIso8601String(),
        'alert_threshold': alertThreshold,
        'alert_fired': alertFired ? 1 : 0,
        'category_id': categoryId,
      };

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
        id: map['id'] as String,
        name: map['name'] as String,
        amount: map['amount'] as double,
        currency: map['currency'] as String,
        period: BudgetPeriod.fromDb(map['period'] as String),
        startDate: DateTime.parse(map['start_date'] as String),
        alertThreshold: map['alert_threshold'] as double,
        alertFired: (map['alert_fired'] as int) == 1,
        categoryId: map['category_id'] as String?,
      );
}
