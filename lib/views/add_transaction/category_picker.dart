import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../viewmodels/transaction_viewmodel.dart';

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final cats = vm.filteredCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cats.map((cat) {
            final selected = vm.selectedCategory?.id == cat.id;
            Color color;
            try {
              color =
                  Color(int.parse('FF${cat.colorHex}', radix: 16));
            } catch (_) {
              color = AppColors.primary;
            }

            return GestureDetector(
              onTap: () {
                context.read<TransactionViewModel>().selectedCategory =
                    selected ? null : cat;
                context.read<TransactionViewModel>().notifyListeners();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      selected ? color.withOpacity(0.15) : Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(
                    color: selected
                        ? color
                        : const Color(0xFFE5E7EB),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icon(cat.iconName),
                      size: 14,
                      color: selected ? color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? color : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _icon(String name) {
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
      'more_horiz': Icons.more_horiz_rounded,
      'work': Icons.work_rounded,
      'laptop': Icons.laptop_rounded,
      'trending_up': Icons.trending_up_rounded,
      'replay': Icons.replay_rounded,
      'attach_money': Icons.attach_money_rounded,
    };
    return map[name] ?? Icons.category_rounded;
  }
}
