import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/card_decoration.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/app_state.dart';

class BudgetVsActualChart extends StatelessWidget {
  const BudgetVsActualChart({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetVm = context.watch<BudgetViewModel>();
    final currency = context.watch<AppState>().currency;

    if (budgetVm.budgets.isEmpty) {
      return Container(
        decoration: cardDecoration(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Center(
          child: Text('No budgets set yet',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final items = budgetVm.budgets.take(5).toList();

    final barGroups = items.asMap().entries.map((entry) {
      final i = entry.key;
      final b = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: b.budget.amount,
            color: AppColors.primary.withOpacity(0.3),
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: b.spent,
            color: b.isOverBudget ? AppColors.expense : AppColors.income,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();

    final maxY = items.fold(0.0, (prev, b) {
      return [prev, b.budget.amount, b.spent].reduce((a, c) => a > c ? a : c);
    });

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Budget vs Actual',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Row(children: [
            _legend(AppColors.primary.withOpacity(0.4), 'Budget'),
            const SizedBox(width: 16),
            _legend(AppColors.income, 'Spent'),
          ]),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.2 + 1,
                barGroups: barGroups,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppColors.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final i = val.toInt();
                        if (i >= items.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            items[i].budget.name.length > 6
                                ? items[i].budget.name.substring(0, 6)
                                : items[i].budget.name,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
