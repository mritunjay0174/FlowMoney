import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../models/enums.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/app_state.dart';
import 'suggestion_chip_row.dart';
import 'amount_input.dart';
import 'category_picker.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<TransactionViewModel>();
    _noteCtrl.text = vm.note;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 8),
              child: Row(
                children: [
                  const Text('Add Transaction',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      context.read<TransactionViewModel>().resetForm();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type toggle
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _TypeTab(
                            label: 'Expense',
                            icon: Icons.arrow_upward_rounded,
                            selected: vm.type == TransactionType.expense,
                            color: AppColors.expense,
                            onTap: () => context
                                .read<TransactionViewModel>()
                                .setType(TransactionType.expense),
                          ),
                          _TypeTab(
                            label: 'Income',
                            icon: Icons.arrow_downward_rounded,
                            selected: vm.type == TransactionType.income,
                            color: AppColors.income,
                            onTap: () => context
                                .read<TransactionViewModel>()
                                .setType(TransactionType.income),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Smart suggestion chips
                    const SuggestionChipRow(),
                    const SizedBox(height: AppSpacing.md),

                    // Amount
                    const AmountInput(),
                    const SizedBox(height: AppSpacing.md),

                    // Category
                    const CategoryPicker(),
                    const SizedBox(height: AppSpacing.md),

                    // Note
                    TextField(
                      controller: _noteCtrl,
                      onChanged: (v) =>
                          context.read<TransactionViewModel>().note = v,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        prefixIcon: Icon(Icons.notes_rounded,
                            color: AppColors.textSecondary),
                      ),
                      maxLength: 100,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Date picker
                    _DateRow(),
                    const SizedBox(height: AppSpacing.lg),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                setState(() => _saving = true);
                                final ok = await context
                                    .read<TransactionViewModel>()
                                    .saveTransaction();
                                setState(() => _saving = false);
                                if (ok && mounted) {
                                  Navigator.pop(context);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              vm.type == TransactionType.expense
                                  ? AppColors.expense
                                  : AppColors.income,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2))
                            : const Text(
                                'Save Transaction',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: selected
                ? Border.all(color: color.withOpacity(0.3))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? color : AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? color : AppColors.textTertiary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final fmt = MaterialLocalizations.of(context);

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: vm.date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                  primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          context.read<TransactionViewModel>().date = picked;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(
              fmt.formatFullDate(vm.date),
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
