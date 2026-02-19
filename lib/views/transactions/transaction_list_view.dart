import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../models/enums.dart';
import '../../models/transaction.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/app_state.dart';
import 'transaction_row.dart';

class TransactionListView extends StatefulWidget {
  const TransactionListView({super.key});

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  String _filter = 'all'; // 'all', 'income', 'expense'
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final currency = context.watch<AppState>().currency;
    final fmt = NumberFormat.currency(name: currency, decimalDigits: 2);

    // Filter transactions
    List<Transaction> filtered = vm.transactions.where((t) {
      if (_filter == 'income' && t.type != TransactionType.income) return false;
      if (_filter == 'expense' && t.type != TransactionType.expense) return false;
      if (_search.isNotEmpty) {
        return t.note.toLowerCase().contains(_search.toLowerCase());
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text('Transactions',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textSecondary),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _search = '');
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Filter chips
                  Row(
                    children: [
                      _FilterChip(
                          label: 'All',
                          selected: _filter == 'all',
                          onTap: () => setState(() => _filter = 'all')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Income',
                          selected: _filter == 'income',
                          color: AppColors.income,
                          onTap: () => setState(() => _filter = 'income')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Expense',
                          selected: _filter == 'expense',
                          color: AppColors.expense,
                          onTap: () => setState(() => _filter = 'expense')),
                      const Spacer(),
                      Text(
                        '${filtered.length} items',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: AppColors.textTertiary),
                    SizedBox(height: 12),
                    Text('No transactions found',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final t = filtered[i];
                    final cat = vm.categories
                        .where((c) => c.id == t.categoryId)
                        .firstOrNull;
                    return TransactionRow(
                      transaction: t,
                      category: cat,
                      currency: currency,
                      onDelete: () => context
                          .read<TransactionViewModel>()
                          .deleteTransaction(t.id),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color = AppColors.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
              color: selected ? color : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
