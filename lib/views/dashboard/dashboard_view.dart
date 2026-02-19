import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/app_state.dart';
import 'balance_summary_card.dart';
import 'smart_suggestions_bar.dart';
import 'recent_transactions_list.dart';
import 'budget_progress_card.dart';
import 'spending_ring_chart.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardViewModel>().load(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    'FlowMoney',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.textPrimary),
                  onPressed: () {},
                ),
              ],
            ),
            if (vm.loading)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const BalanceSummaryCard(),
                    const SizedBox(height: AppSpacing.md),
                    const SmartSuggestionsBar(),
                    const SizedBox(height: AppSpacing.md),
                    if (vm.budgets.isNotEmpty) ...[
                      const BudgetProgressCard(),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (vm.categorySpending.isNotEmpty) ...[
                      const SpendingRingChart(),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const RecentTransactionsList(),
                    const SizedBox(height: 80), // FAB clearance
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}
