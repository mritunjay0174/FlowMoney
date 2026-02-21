import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
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
    final appState = context.watch<AppState>();
    final name = appState.userName;
    final greetingText = _greeting(name);

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
                    greetingText,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    name.isNotEmpty ? name : 'FlowMoney',
                    style: const TextStyle(
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
                  onPressed: () => _showNotificationsSheet(context, appState),
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
                        const Icon(Icons.cloud_off_rounded,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Could not load data',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Pull down to retry',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
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

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    if (name.isNotEmpty) {
      return '$timeGreeting, $name 👋';
    }
    return '$timeGreeting 👋';
  }

  void _showNotificationsSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: appState,
        child: const _NotificationsSheet(),
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Notifications',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: SwitchListTile(
              title: const Text(
                'Budget Alerts',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              subtitle: Text(
                'Get notified when you reach 80% of a budget',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              value: appState.notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) => appState.setNotificationsEnabled(val),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Info card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    'Notifications fire automatically when you approach your budget limits. You can manage budgets in the Budgets tab.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Recent alerts placeholder
          Row(
            children: [
              const Text(
                'Recent Alerts',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Column(
              children: [
                Icon(Icons.notifications_none_rounded,
                    size: 36, color: Colors.grey[300]),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No recent alerts',
                  style: TextStyle(
                      color: AppColors.textTertiary, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
