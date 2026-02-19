import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../design/app_colors.dart';
import '../design/card_decoration.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/analytics_viewmodel.dart';
import '../viewmodels/budget_viewmodel.dart';
import '../viewmodels/app_state.dart';
import 'dashboard/dashboard_view.dart';
import 'transactions/transaction_list_view.dart';
import 'analytics/analytics_view.dart';
import 'budget/budget_list_view.dart';
import 'settings/settings_view.dart';
import 'add_transaction/add_transaction_sheet.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appState = context.read<AppState>();
    final currency = appState.currency;

    await Future.wait([
      context.read<DashboardViewModel>().load(),
      context.read<TransactionViewModel>().loadAll(currency),
      context.read<AnalyticsViewModel>().load(),
      context.read<BudgetViewModel>().load(),
    ]);
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    ).then((_) {
      // Refresh dashboard after adding transaction
      context.read<DashboardViewModel>().load();
      context.read<AnalyticsViewModel>().load();
      context.read<BudgetViewModel>().load();
    });
  }

  static const _pages = [
    DashboardView(),
    TransactionListView(),
    AnalyticsView(),
    BudgetListView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: _selectedIndex != 4
          ? GestureDetector(
              onTap: _showAddTransaction,
              child: Container(
                width: 60,
                height: 60,
                decoration: primaryGradientDecoration(radius: 30),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  selected: _selectedIndex == 0,
                  onTap: _onTabTapped,
                ),
                _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'History',
                  index: 1,
                  selected: _selectedIndex == 1,
                  onTap: _onTabTapped,
                ),
                // FAB spacer
                const Expanded(child: SizedBox()),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  index: 2,
                  selected: _selectedIndex == 2,
                  onTap: _onTabTapped,
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Budgets',
                  index: 3,
                  selected: _selectedIndex == 3,
                  onTap: _onTabTapped,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: selected
                  ? BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textTertiary,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
