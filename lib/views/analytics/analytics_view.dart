import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../viewmodels/analytics_viewmodel.dart';
import 'trend_line_chart.dart';
import 'spending_breakdown_chart.dart';
import 'budget_vs_actual_chart.dart';
import 'monthly_heatmap.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => context.read<AnalyticsViewModel>().load(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              title: const Text(
                'Analytics',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded,
                      color: AppColors.textPrimary),
                  onPressed: () => _showMonthPicker(context, vm),
                ),
              ],
            ),
            if (vm.loading)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary)),
              )
            else if (vm.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bar_chart_rounded,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Could not load analytics',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Pull down to retry',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (vm.trendData.isEmpty && vm.categoryData.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.bar_chart_rounded,
                              size: 56, color: AppColors.primary),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'No data yet',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Add some transactions using the + button\nand your analytics will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Month selector chip
                    _MonthChip(vm: vm),
                    const SizedBox(height: AppSpacing.md),

                    // Income vs Expense trend
                    const TrendLineChart(),
                    const SizedBox(height: AppSpacing.md),

                    // Spending breakdown pie
                    const SpendingBreakdownChart(),
                    const SizedBox(height: AppSpacing.md),

                    // Monthly heatmap
                    const MonthlyHeatmap(),
                    const SizedBox(height: AppSpacing.md),

                    // Budget vs Actual
                    const BudgetVsActualChart(),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context, AnalyticsViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final now = DateTime.now();
        final months = List.generate(12, (i) {
          return DateTime(now.year, now.month - i);
        });
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Month',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            ...months.map((m) {
              final selected = vm.selectedMonth == m.month &&
                  vm.selectedYear == m.year;
              return ListTile(
                title: Text(
                    '${_monthName(m.month)} ${m.year}',
                    style: TextStyle(
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    )),
                trailing: selected
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  vm.selectMonth(m.year, m.month);
                },
              );
            }),
          ],
        );
      },
    );
  }

  String _monthName(int m) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[m];
  }
}

class _MonthChip extends StatelessWidget {
  final AnalyticsViewModel vm;
  const _MonthChip({required this.vm});

  @override
  Widget build(BuildContext context) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return Chip(
      avatar: const Icon(Icons.calendar_month_rounded,
          size: 16, color: AppColors.primary),
      label: Text('${names[vm.selectedMonth]} ${vm.selectedYear}',
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.primary)),
      backgroundColor: AppColors.primary.withOpacity(0.08),
      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
    );
  }
}
