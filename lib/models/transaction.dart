import 'enums.dart';

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String? categoryId;
  final String note;
  final DateTime date;
  final String currency;
  final int hourOfDay;
  final int dayOfWeek;
  final bool suggestionWasUsed;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.note,
    required this.date,
    required this.currency,
    required this.hourOfDay,
    required this.dayOfWeek,
    this.suggestionWasUsed = false,
    required this.createdAt,
  });

  factory Transaction.create({
    required String id,
    required double amount,
    required TransactionType type,
    String? categoryId,
    String note = '',
    DateTime? date,
    required String currency,
    bool suggestionWasUsed = false,
  }) {
    final now = date ?? DateTime.now();
    return Transaction(
      id: id,
      amount: amount,
      type: type,
      categoryId: categoryId,
      note: note,
      date: now,
      currency: currency,
      hourOfDay: now.hour,
      dayOfWeek: now.weekday, // 1=Mon, 7=Sun
      suggestionWasUsed: suggestionWasUsed,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'type': type.dbValue,
        'category_id': categoryId,
        'note': note,
        'date': date.toIso8601String(),
        'currency': currency,
        'hour_of_day': hourOfDay,
        'day_of_week': dayOfWeek,
        'suggestion_was_used': suggestionWasUsed ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as String,
        amount: map['amount'] as double,
        type: TransactionType.fromDb(map['type'] as String),
        categoryId: map['category_id'] as String?,
        note: map['note'] as String,
        date: DateTime.parse(map['date'] as String),
        currency: map['currency'] as String,
        hourOfDay: map['hour_of_day'] as int,
        dayOfWeek: map['day_of_week'] as int,
        suggestionWasUsed: (map['suggestion_was_used'] as int) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Transaction copyWith({
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? note,
    DateTime? date,
    String? currency,
  }) {
    return Transaction(
      id: id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      hourOfDay: (date ?? this.date).hour,
      dayOfWeek: (date ?? this.date).weekday,
      suggestionWasUsed: suggestionWasUsed,
      createdAt: createdAt,
    );
  }
}
