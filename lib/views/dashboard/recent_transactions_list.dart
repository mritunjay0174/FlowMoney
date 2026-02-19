import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/card_decoration.dart';
import '../../models/enums.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/app_state.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final currency = context.watch<AppState>().currency;
    final fmt = NumberFormat.currency(name: currency, decimalDigits: 2);
    final dateFmt = DateFormat('MMM d');

    if (vm.recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: cardDecoration(),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 48, color: AppColors.textTertiary),
              SizedBox(height: AppSpacing.sm),
              Text('No transactions yet',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              Text('Tap + to add your first transaction',
                  style: TextStyle(
                      color: AppColors.textTertiary, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: vm.recent.length.clamp(0, 10),
            separatorBuilder: (_, __) => const Divider(
                height: 1, indent: 72, color: AppColors.divider),
            itemBuilder: (_, i) {
              final t = vm.recent[i];
              final cat = vm.categoryFor(t.categoryId);
              final isIncome = t.type == TransactionType.income;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 4),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isIncome ? AppColors.income : AppColors.expense)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconForCategory(cat?.iconName),
                    color: isIncome ? AppColors.income : AppColors.expense,
                    size: 20,
                  ),
                ),
                title: Text(
                  t.note.isNotEmpty ? t.note : cat?.name ?? 'Transaction',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${cat?.name ?? 'Uncategorized'}  ·  ${dateFmt.format(t.date)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textTertiary),
                ),
                trailing: Text(
                  '${isIncome ? '+' : '-'}${fmt.format(t.amount)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isIncome ? AppColors.income : AppColors.expense,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  IconData _iconForCategory(String? iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant_rounded;
      case 'local_cafe': return Icons.local_cafe_rounded;
      case 'shopping_cart': return Icons.shopping_cart_rounded;
      case 'directions_car': return Icons.directions_car_rounded;
      case 'shopping_bag': return Icons.shopping_bag_rounded;
      case 'movie': return Icons.movie_rounded;
      case 'fitness_center': return Icons.fitness_center_rounded;
      case 'receipt_long': return Icons.receipt_long_rounded;
      case 'home': return Icons.home_rounded;
      case 'school': return Icons.school_rounded;
      case 'flight': return Icons.flight_rounded;
      case 'spa': return Icons.spa_rounded;
      case 'card_giftcard': return Icons.card_giftcard_rounded;
      case 'pets': return Icons.pets_rounded;
      case 'work': return Icons.work_rounded;
      case 'laptop': return Icons.laptop_rounded;
      case 'trending_up': return Icons.trending_up_rounded;
      case 'attach_money': return Icons.attach_money_rounded;
      default: return Icons.receipt_rounded;
    }
  }
}
