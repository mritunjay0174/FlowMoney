import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/recurring_pattern.dart';
import '../models/enums.dart';
import '../services/database_service.dart';
import 'suggestion_engine.dart';

class TransactionViewModel extends ChangeNotifier {
  final DatabaseService _db;
  final SuggestionEngine _engine = SuggestionEngine();
  static const _uuid = Uuid();

  TransactionViewModel(this._db);

  // Form state
  double amount = 0.0;
  TransactionType type = TransactionType.expense;
  Category? selectedCategory;
  String note = '';
  DateTime date = DateTime.now();
  String currency = 'USD';
  bool _suggestionWasUsed = false;

  // Lists
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  List<RecurringPattern> _patterns = [];
  List<SuggestedPattern> _suggestions = [];

  bool _loading = false;

  List<Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;
  List<RecurringPattern> get patterns => _patterns;
  List<SuggestedPattern> get suggestions => _suggestions;
  bool get loading => _loading;

  List<Category> get filteredCategories =>
      _categories.where((c) => c.type == type).toList();

  Future<void> loadAll(String currency) async {
    this.currency = currency;
    _loading = true;
    notifyListeners();

    _transactions = await _db.getAllTransactions();
    _categories = await _db.getAllCategories();
    _patterns = await _db.getAllPatterns();
    _refreshSuggestions();
    _loading = false;
    notifyListeners();
  }

  void _refreshSuggestions() {
    _suggestions = _engine.topSuggestions(_patterns, DateTime.now());
  }

  void applySuggestion(SuggestedPattern s) {
    note = s.pattern.name;
    amount = s.pattern.typicalAmount;
    type = TransactionType.expense;
    _suggestionWasUsed = true;
    notifyListeners();
  }

  void resetForm() {
    amount = 0.0;
    type = TransactionType.expense;
    selectedCategory = null;
    note = '';
    date = DateTime.now();
    _suggestionWasUsed = false;
    notifyListeners();
  }

  void setType(TransactionType t) {
    type = t;
    if (selectedCategory != null && selectedCategory!.type != t) {
      selectedCategory = null;
    }
    notifyListeners();
  }

  Future<bool> saveTransaction() async {
    if (amount <= 0) return false;

    final txn = Transaction.create(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      categoryId: selectedCategory?.id,
      note: note,
      date: date,
      currency: currency,
      suggestionWasUsed: _suggestionWasUsed,
    );

    await _db.insertTransaction(txn);
    _transactions.insert(0, txn);

    // Update matching pattern (Welford learning)
    if (_suggestionWasUsed) {
      final matchedPattern = _patterns.firstWhere(
        (p) => p.name.toLowerCase() == note.toLowerCase(),
        orElse: () => RecurringPattern(
          id: '',
          name: '',
          typicalAmount: 0,
          currency: currency,
          preferredHour: 0,
          activeDays: [],
          source: PatternSource.onboarding,
        ),
      );
      if (matchedPattern.id.isNotEmpty) {
        _engine.updatePattern(matchedPattern, txn.hourOfDay);
        await _db.updatePattern(matchedPattern);
      }
    }

    // Auto-discovery every 10 transactions
    if (_transactions.length % 10 == 0) {
      await _engine.discoverPatterns(
          _transactions, _patterns, _db, currency);
      _patterns = await _db.getAllPatterns();
    }

    _refreshSuggestions();
    resetForm();
    notifyListeners();
    return true;
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<List<Transaction>> getTransactions({
    String? typeFilter,
    String? categoryId,
    DateTime? from,
    DateTime? to,
  }) async {
    return _db.getAllTransactions(
      type: typeFilter,
      categoryId: categoryId,
      from: from,
      to: to,
    );
  }
}
