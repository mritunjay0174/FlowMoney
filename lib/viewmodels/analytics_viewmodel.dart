import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class ChartDataPoint {
  final DateTime date;
  final double income;
  final double expense;

  const ChartDataPoint({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class CategorySpend {
  final Category? category;
  final String label;
  final double amount;
  final String colorHex;

  const CategorySpend({
    this.category,
    required this.label,
    required this.amount,
    required this.colorHex,
  });
}

class AnalyticsViewModel extends ChangeNotifier {
  final DatabaseService _db;

  AnalyticsViewModel(this._db);

  List<ChartDataPoint> _trendData = [];
  List<CategorySpend> _categoryData = [];
  Map<int, double> _heatmapData = {};
  List<Category> _categories = [];
  bool _loading = false;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<ChartDataPoint> get trendData => _trendData;
  List<CategorySpend> get categoryData => _categoryData;
  Map<int, double> get heatmapData => _heatmapData;
  bool get loading => _loading;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _categories = await _db.getAllCategories();
    await _loadTrend();
    await _loadCategories();
    await _loadHeatmap();

    _loading = false;
    notifyListeners();
  }

  Future<void> selectMonth(int year, int month) async {
    _selectedYear = year;
    _selectedMonth = month;
    _loading = true;
    notifyListeners();

    await _loadCategories();
    await _loadHeatmap();

    _loading = false;
    notifyListeners();
  }

  Future<void> _loadTrend() async {
    final rows = await _db.getDailyTotals(30);
    _trendData = rows.map((r) {
      return ChartDataPoint(
        date: DateTime.parse(r['date'] as String),
        income: r['income'] as double,
        expense: r['expense'] as double,
      );
    }).toList();
  }

  Future<void> _loadCategories() async {
    final from = DateTime(_selectedYear, _selectedMonth, 1);
    final to = DateTime(_selectedYear, _selectedMonth + 1, 1);
    final totals = await _db.getCategoryTotals(from: from, to: to);
    _categoryData = totals.entries.map((e) {
      Category? cat;
      try {
        cat = _categories.firstWhere((c) => c.id == e.key);
      } catch (_) {}
      return CategorySpend(
        category: cat,
        label: cat?.name ?? 'Other',
        amount: e.value,
        colorHex: cat?.colorHex ?? '9CA3AF',
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  Future<void> _loadHeatmap() async {
    _heatmapData = await _db.getDailySpendMap(_selectedYear, _selectedMonth);
  }

  double get maxDailySpend {
    if (_heatmapData.isEmpty) return 1.0;
    return _heatmapData.values.reduce((a, b) => a > b ? a : b);
  }
}
