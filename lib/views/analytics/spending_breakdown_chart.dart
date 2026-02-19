import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/card_decoration.dart';
import '../../viewmodels/analytics_viewmodel.dart';

class SpendingBreakdownChart extends StatefulWidget {
  const SpendingBreakdownChart({super.key});

  @override
  State<SpendingBreakdownChart> createState() =>
      _SpendingBreakdownChartState();
}

class _SpendingBreakdownChartState
    extends State<SpendingBreakdownChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();
    final data = vm.categoryData;

    if (data.isEmpty) {
      return Container(
        decoration: cardDecoration(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Center(
          child: Text('No spending data this month',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final total = data.fold(0.0, (s, d) => s + d.amount);
    final sections = data.asMap().entries.map((entry) {
      final i = entry.key;
      final d = entry.value;
      final isTouched = i == _touched;
      Color color;
      try {
        color = Color(int.parse('FF${d.colorHex}', radix: 16));
      } catch (_) {
        color = AppColors.categoryColors[i % AppColors.categoryColors.length];
      }
      final pct = total > 0 ? d.amount / total * 100 : 0.0;
      return PieChartSectionData(
        value: d.amount,
        color: color,
        radius: isTouched ? 70 : 56,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white),
      );
    }).toList();

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spending Breakdown',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 36,
                    sectionsSpace: 3,
                    pieTouchData: PieTouchData(
                      touchCallback:
                          (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touched = -1;
                            return;
                          }
                          _touched = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.take(6).toList().asMap().entries.map((e) {
                    final d = e.value;
                    Color color;
                    try {
                      color = Color(
                          int.parse('FF${d.colorHex}', radix: 16));
                    } catch (_) {
                      color = AppColors.categoryColors[
                          e.key % AppColors.categoryColors.length];
                    }
                    final pct =
                        total > 0 ? d.amount / total * 100 : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(d.label,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
