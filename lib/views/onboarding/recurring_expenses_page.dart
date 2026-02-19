import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../viewmodels/onboarding_viewmodel.dart';

class RecurringExpensesPage extends StatelessWidget {
  const RecurringExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.income.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.repeat_rounded,
                        color: AppColors.income, size: 28),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Daily Habits',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary),
                  ),
                  const Text(
                    'Tap to add your regular expenses. We\'ll remind you at the right time.',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.4,
                ),
                itemCount: vm.presets.length + 1,
                itemBuilder: (context, i) {
                  if (i == vm.presets.length) {
                    return _addCustomCard(context);
                  }
                  final expense = vm.presets[i];
                  return _ExpenseCard(
                    expense: expense,
                    onTap: () => vm.togglePreset(i),
                    onEdit: () =>
                        _showEditDialog(context, vm, i),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          context.read<OnboardingViewModel>().prevPage(),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () =>
                          context.read<OnboardingViewModel>().nextPage(),
                      child: Text(vm.selectedExpenses.isEmpty
                          ? 'Skip'
                          : 'Continue (${vm.selectedExpenses.length})'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addCustomCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddCustomDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
              color: const Color(0xFFE5E7EB),
              style: BorderStyle.solid,
              width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                size: 32, color: AppColors.textTertiary),
            SizedBox(height: 6),
            Text('Add Custom',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, OnboardingViewModel vm, int index) {
    final expense = vm.presets[index];
    final amountCtrl =
        TextEditingController(text: expense.amount > 0 ? expense.amount.toString() : '');
    int hour = expense.hour;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${expense.emoji} ${expense.name}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Typical Amount', prefixText: '\$ '),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Preferred time: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('${hour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Slider(
                    value: hour.toDouble(),
                    min: 0,
                    max: 23,
                    divisions: 23,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      setState(() => hour = v.round());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text) ?? 0;
                    vm.updatePresetAmount(index, amt);
                    vm.updatePresetHour(index, hour);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCustomDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    int hour = 12;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Custom Expense',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Expense Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Typical Amount', prefixText: '\$ '),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Time: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('${hour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  Expanded(
                    child: Slider(
                      value: hour.toDouble(),
                      min: 0,
                      max: 23,
                      divisions: 23,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => hour = v.round()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      final amt = double.tryParse(amountCtrl.text) ?? 0;
                      context
                          .read<OnboardingViewModel>()
                          .addCustomExpense(
                            nameCtrl.text.trim(),
                            '💳',
                            amt,
                            hour,
                          );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final OnboardingExpense expense;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _ExpenseCard({
    required this.expense,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: expense.selected ? onEdit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: expense.selected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: expense.selected
                ? AppColors.primary
                : const Color(0xFFE5E7EB),
            width: expense.selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(expense.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              expense.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: expense.selected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${expense.hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                fontSize: 11,
                color: expense.selected
                    ? AppColors.primary.withOpacity(0.7)
                    : AppColors.textTertiary,
              ),
            ),
            if (expense.selected && expense.amount > 0)
              Text(
                '\$${expense.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.income),
              ),
          ],
        ),
      ),
    );
  }
}
