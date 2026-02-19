import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../add_transaction/add_transaction_sheet.dart';

class SmartSuggestionsBar extends StatelessWidget {
  const SmartSuggestionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final suggestions = vm.suggestions;
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final hour = DateTime.now().hour;
    String timeLabel;
    if (hour >= 6 && hour < 10) timeLabel = '🌅 Morning suggestions';
    else if (hour >= 10 && hour < 14) timeLabel = '☀️ Lunch time';
    else if (hour >= 14 && hour < 18) timeLabel = '🌤 Afternoon';
    else if (hour >= 18 && hour < 22) timeLabel = '🌆 Evening';
    else timeLabel = '🌙 Night';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            timeLabel,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = suggestions[i];
              return GestureDetector(
                onTap: () {
                  vm.applySuggestion(s);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddTransactionSheet(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        s.pattern.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      if (s.pattern.typicalAmount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '\$${s.pattern.typicalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                AppColors.primary.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
