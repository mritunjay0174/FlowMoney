enum TransactionType {
  income,
  expense;

  String get label => name[0].toUpperCase() + name.substring(1);

  String get dbValue => name;

  static TransactionType fromDb(String value) =>
      TransactionType.values.firstWhere((e) => e.name == value);
}

enum PatternSource {
  onboarding,
  learned;

  String get dbValue => name;

  static PatternSource fromDb(String value) =>
      PatternSource.values.firstWhere((e) => e.name == value);
}

enum BudgetPeriod {
  weekly,
  monthly,
  yearly;

  String get label => name[0].toUpperCase() + name.substring(1);

  String get dbValue => name;

  static BudgetPeriod fromDb(String value) =>
      BudgetPeriod.values.firstWhere((e) => e.name == value);
}
