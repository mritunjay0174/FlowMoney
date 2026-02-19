import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/card_decoration.dart';
import '../../viewmodels/analytics_viewmodel.dart';

class MonthlyHeatmap extends StatelessWidget {
  const MonthlyHeatmap({super.key});

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();
    final heatmap = vm.heatmapData;
    final maxSpend = vm.maxDailySpend;

    // Build 5-week grid (35 cells)
    final now = DateTime.now();
    final firstDay = DateTime(vm.selectedYear, vm.selectedMonth, 1);
    final daysInMonth = DateTime(vm.selectedYear, vm.selectedMonth + 1, 0).day;
    // Offset so Monday=0 ... Sun=6
    final startOffset = (firstDay.weekday - 1) % 7;

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Spending Heatmap',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Darker = more spending',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          // Day labels
          Row(
            children: _dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: 35,
            itemBuilder: (_, index) {
              final dayNum = index - startOffset + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }

              final spend = heatmap[dayNum] ?? 0.0;
              final intensity =
                  maxSpend > 0 ? (spend / maxSpend).clamp(0.0, 1.0) : 0.0;

              final isToday = now.year == vm.selectedYear &&
                  now.month == vm.selectedMonth &&
                  now.day == dayNum;

              return Tooltip(
                message: '\$$spend',
                child: Container(
                  decoration: BoxDecoration(
                    color: spend == 0
                        ? AppColors.background
                        : AppColors.expense
                            .withOpacity(0.15 + intensity * 0.75),
                    borderRadius: BorderRadius.circular(4),
                    border: isToday
                        ? Border.all(
                            color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: intensity > 0.5
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          // Legend
          Row(
            children: [
              const Text('Less',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary)),
              const SizedBox(width: 6),
              ...List.generate(5, (i) {
                final opacity = 0.15 + i * 0.17;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.expense.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
              const SizedBox(width: 6),
              const Text('More',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}
