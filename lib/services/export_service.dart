import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final _dateFmt = DateFormat('yyyy-MM-dd');
  final _timeFmt = DateFormat('HH:mm');

  Future<void> exportCsv(
    List<Transaction> transactions,
    List<Category> categories,
  ) async {
    final catMap = {for (final c in categories) c.id: c};

    final rows = <List<dynamic>>[
      ['Date', 'Time', 'Type', 'Category', 'Note', 'Amount', 'Currency'],
      ...transactions.map((t) => [
            _dateFmt.format(t.date),
            _timeFmt.format(t.date),
            t.type.label,
            catMap[t.categoryId]?.name ?? '',
            t.note,
            t.amount,
            t.currency,
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/flowmoney_export.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'FlowMoney Transactions Export',
    );
  }

  Future<void> exportXlsx(
    List<Transaction> transactions,
    List<Category> categories,
  ) async {
    final catMap = {for (final c in categories) c.id: c};
    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    // Header row
    final headers = [
      'Date', 'Time', 'Type', 'Category', 'Note', 'Amount', 'Currency',
    ];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // Data rows
    for (var r = 0; r < transactions.length; r++) {
      final t = transactions[r];
      final values = [
        _dateFmt.format(t.date),
        _timeFmt.format(t.date),
        t.type.label,
        catMap[t.categoryId]?.name ?? '',
        t.note,
        t.amount,
        t.currency,
      ];
      for (var c = 0; c < values.length; c++) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
        final v = values[c];
        if (v is double) {
          cell.value = DoubleCellValue(v);
        } else {
          cell.value = TextCellValue(v.toString());
        }
      }
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/flowmoney_export.xlsx');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'FlowMoney Transactions Export',
    );
  }
}
