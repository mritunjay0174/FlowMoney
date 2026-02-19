import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../models/enums.dart';

class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final String currency;
  final VoidCallback onDelete;

  const TransactionRow({
    super.key,
    required this.transaction,
    this.category,
    required this.currency,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final fmt = NumberFormat.currency(name: currency, decimalDigits: 2);
    final dateFmt = DateFormat('MMM d, yyyy · HH:mm');

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.expense.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.expense),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text(
                'Are you sure you want to delete this transaction?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.expense),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconForCategory(category?.iconName),
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            transaction.note.isNotEmpty
                ? transaction.note
                : category?.name ?? 'Transaction',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${category?.name ?? 'Uncategorized'}  ·  ${dateFmt.format(transaction.date)}',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textTertiary),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${fmt.format(transaction.amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (transaction.suggestionWasUsed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded,
                        size: 10,
                        color:
                            AppColors.primary.withOpacity(0.6)),
                    const Text('smart',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String? iconName) {
    const map = {
      'restaurant': Icons.restaurant_rounded,
      'local_cafe': Icons.local_cafe_rounded,
      'shopping_cart': Icons.shopping_cart_rounded,
      'directions_car': Icons.directions_car_rounded,
      'shopping_bag': Icons.shopping_bag_rounded,
      'movie': Icons.movie_rounded,
      'fitness_center': Icons.fitness_center_rounded,
      'receipt_long': Icons.receipt_long_rounded,
      'home': Icons.home_rounded,
      'school': Icons.school_rounded,
      'flight': Icons.flight_rounded,
      'spa': Icons.spa_rounded,
      'card_giftcard': Icons.card_giftcard_rounded,
      'pets': Icons.pets_rounded,
      'work': Icons.work_rounded,
      'laptop': Icons.laptop_rounded,
      'trending_up': Icons.trending_up_rounded,
      'replay': Icons.replay_rounded,
      'attach_money': Icons.attach_money_rounded,
    };
    return map[iconName] ?? Icons.receipt_rounded;
  }
}
