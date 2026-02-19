import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/card_decoration.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/app_state.dart';

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final currency = context.watch<AppState>().currency;
    final fmt = NumberFormat.currency(name: currency, decimalDigits: 0);

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Overview',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          ...vm.budgets.take(3).map((b) {
            final spent = vm.monthExpense; // simplified
            final pct = (b.amount > 0
                    ? (spent / b.amount).clamp(0.0, 1.0)
                    : 0.0);
            final color = pct >= 1.0
                ? AppColors.expense
                : pct >= 0.8
                    ? AppColors.warning
                    : AppColors.income;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(b.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textPrimary)),
                      ),
                      Text(
                        '${fmt.format(spent)} / ${fmt.format(b.amount)}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
