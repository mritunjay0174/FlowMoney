import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../models/enums.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/app_state.dart';

class AmountInput extends StatefulWidget {
  const AmountInput({super.key});

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final vm = context.read<TransactionViewModel>();
    _ctrl = TextEditingController(
      text: vm.amount > 0 ? vm.amount.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final currency = context.watch<AppState>().currency;
    final isExpense = vm.type == TransactionType.expense;
    final accentColor = isExpense ? AppColors.expense : AppColors.income;

    return Container(
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Amount',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: accentColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _currencySymbol(currency),
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: accentColor),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) {
                    context.read<TransactionViewModel>().amount =
                        double.tryParse(v) ?? 0;
                  },
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                        color: accentColor.withOpacity(0.3),
                        fontSize: 40,
                        fontWeight: FontWeight.w900),
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlign: TextAlign.center,
                  autofocus: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _currencySymbol(String code) {
    const map = {
      'USD': '\$', 'EUR': '€', 'GBP': '£', 'INR': '₹',
      'JPY': '¥', 'KWD': 'KD', 'AED': 'AED', 'SAR': 'SAR',
    };
    return map[code] ?? code;
  }
}
