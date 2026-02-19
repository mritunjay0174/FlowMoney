import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/recurring_pattern.dart';
import '../models/budget.dart';
import '../models/enums.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flowmoney.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT,
        note TEXT NOT NULL DEFAULT '',
        date TEXT NOT NULL,
        currency TEXT NOT NULL,
        hour_of_day INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL,
        suggestion_was_used INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        type TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_system INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_patterns (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category_id TEXT,
        typical_amount REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL,
        preferred_hour INTEGER NOT NULL,
        preferred_hour_variance REAL NOT NULL DEFAULT 1.0,
        active_days TEXT NOT NULL DEFAULT '[]',
        occurrence_count INTEGER NOT NULL DEFAULT 1,
        last_occurrence TEXT,
        source TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        period TEXT NOT NULL,
        start_date TEXT NOT NULL,
        alert_threshold REAL NOT NULL DEFAULT 0.80,
        alert_fired INTEGER NOT NULL DEFAULT 0,
        category_id TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_txn_date ON transactions(date)',
    );
    await db.execute(
      'CREATE INDEX idx_txn_type ON transactions(type)',
    );
  }

  // ─── TRANSACTIONS ─────────────────────────────────────────────────────────

  Future<void> insertTransaction(Transaction t) async {
    final d = await db;
    await d.insert('transactions', t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTransaction(String id) async {
    final d = await db;
    await d.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Transaction>> getAllTransactions({
    String? type,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final d = await db;
    final where = <String>[];
    final args = <dynamic>[];

    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (categoryId != null) {
      where.add('category_id = ?');
      args.add(categoryId);
    }
    if (from != null) {
      where.add('date >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where.add('date <= ?');
      args.add(to.toIso8601String());
    }

    final rows = await d.query(
      'transactions',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC',
      limit: limit,
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<List<Transaction>> getTransactionsByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return getAllTransactions(from: start, to: end);
  }

  Future<double> getTotalByType(TransactionType type,
      {DateTime? from, DateTime? to}) async {
    final d = await db;
    final where = <String>['type = ?'];
    final args = <dynamic>[type.dbValue];
    if (from != null) {
      where.add('date >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where.add('date <= ?');
      args.add(to.toIso8601String());
    }
    final result = await d.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE ${where.join(' AND ')}',
      args,
    );
    return (result.first['total'] as num).toDouble();
  }

  // ─── CATEGORIES ────────────────────────────────────────────────────────────

  Future<void> insertCategory(Category c) async {
    final d = await db;
    await d.insert('categories', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCategory(Category c) async {
    final d = await db;
    await d.update('categories', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
  }

  Future<void> deleteCategory(String id) async {
    final d = await db;
    await d.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Category>> getAllCategories({TransactionType? type}) async {
    final d = await db;
    final rows = await d.query(
      'categories',
      where: type != null ? 'type = ?' : null,
      whereArgs: type != null ? [type.dbValue] : null,
      orderBy: 'sort_order ASC',
    );
    return rows.map(Category.fromMap).toList();
  }

  Future<Category?> getCategoryById(String id) async {
    final d = await db;
    final rows =
        await d.query('categories', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Category.fromMap(rows.first);
  }

  // ─── RECURRING PATTERNS ───────────────────────────────────────────────────

  Future<void> insertPattern(RecurringPattern p) async {
    final d = await db;
    await d.insert('recurring_patterns', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePattern(RecurringPattern p) async {
    final d = await db;
    await d.update('recurring_patterns', p.toMap(),
        where: 'id = ?', whereArgs: [p.id]);
  }

  Future<void> deletePattern(String id) async {
    final d = await db;
    await d.delete('recurring_patterns',
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RecurringPattern>> getAllPatterns() async {
    final d = await db;
    final rows = await d.query('recurring_patterns',
        orderBy: 'occurrence_count DESC');
    return rows.map(RecurringPattern.fromMap).toList();
  }

  // ─── BUDGETS ─────────────────────────────────────────────────────────────

  Future<void> insertBudget(Budget b) async {
    final d = await db;
    await d.insert('budgets', b.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBudget(Budget b) async {
    final d = await db;
    await d.update('budgets', b.toMap(),
        where: 'id = ?', whereArgs: [b.id]);
  }

  Future<void> deleteBudget(String id) async {
    final d = await db;
    await d.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Budget>> getAllBudgets() async {
    final d = await db;
    final rows = await d.query('budgets', orderBy: 'name ASC');
    return rows.map(Budget.fromMap).toList();
  }

  // ─── ANALYTICS HELPERS ───────────────────────────────────────────────────

  /// Returns daily spend totals for the given month as a map {day: total}
  Future<Map<int, double>> getDailySpendMap(int year, int month) async {
    final d = await db;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();
    final rows = await d.rawQuery('''
      SELECT CAST(strftime('%d', date) AS INTEGER) as day,
             SUM(amount) as total
      FROM transactions
      WHERE type = 'expense' AND date >= ? AND date < ?
      GROUP BY day
    ''', [start, end]);
    return {
      for (final r in rows)
        r['day'] as int: (r['total'] as num).toDouble(),
    };
  }

  /// Returns category spending totals for the given month
  Future<Map<String, double>> getCategoryTotals(
      {DateTime? from, DateTime? to}) async {
    final d = await db;
    final where = <String>['type = ?'];
    final args = <dynamic>['expense'];
    if (from != null) {
      where.add('date >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where.add('date < ?');
      args.add(to.toIso8601String());
    }
    final rows = await d.rawQuery('''
      SELECT category_id, SUM(amount) as total
      FROM transactions
      WHERE ${where.join(' AND ')}
      GROUP BY category_id
    ''', args);
    return {
      for (final r in rows)
        (r['category_id'] as String? ?? 'uncategorized'):
            (r['total'] as num).toDouble(),
    };
  }

  /// Returns [{date: '...', income: X, expense: Y}] for last N days
  Future<List<Map<String, dynamic>>> getDailyTotals(int days) async {
    final d = await db;
    final from =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final rows = await d.rawQuery('''
      SELECT date(date) as day,
             SUM(CASE WHEN type='income' THEN amount ELSE 0 END) as income,
             SUM(CASE WHEN type='expense' THEN amount ELSE 0 END) as expense
      FROM transactions
      WHERE date >= ?
      GROUP BY day
      ORDER BY day ASC
    ''', [from]);
    return rows
        .map((r) => {
              'date': r['day'],
              'income': (r['income'] as num).toDouble(),
              'expense': (r['expense'] as num).toDouble(),
            })
        .toList();
  }

  // ─── CLEAR ALL ──────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    final d = await db;
    await d.delete('transactions');
    await d.delete('recurring_patterns');
    await d.delete('budgets');
    // Keep system categories
    await d.delete('categories', where: 'is_system = ?', whereArgs: [0]);
  }
}
