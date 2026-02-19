import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/card_decoration.dart';
import '../../viewmodels/app_state.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../services/export_service.dart';
import '../../services/database_service.dart';
import '../../services/data_seeder.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text('Settings',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary)),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile card
                Container(
                  decoration: primaryGradientDecoration(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FlowMoney',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          Text(
                            'Currency: ${appState.currency}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Appearance
                _SectionHeader(title: 'Appearance'),
                Container(
                  decoration: cardDecoration(),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        iconColor: const Color(0xFF6366F1),
                        title: 'Theme',
                        subtitle: appState.themeMode == ThemeMode.system
                            ? 'System'
                            : appState.themeMode == ThemeMode.dark
                                ? 'Dark'
                                : 'Light',
                        onTap: () => _showThemePicker(context, appState),
                      ),
                      const Divider(height: 1, indent: 60),
                      _SettingsTile(
                        icon: Icons.currency_exchange_rounded,
                        iconColor: const Color(0xFF10B981),
                        title: 'Currency',
                        subtitle: appState.currency,
                        onTap: () => _showCurrencyPicker(context, appState),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Notifications
                _SectionHeader(title: 'Notifications'),
                Container(
                  decoration: cardDecoration(),
                  child: _SettingsTile(
                    icon: Icons.notifications_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Budget Alerts',
                    subtitle: appState.notificationsEnabled
                        ? 'Enabled'
                        : 'Disabled',
                    trailing: Switch(
                      value: appState.notificationsEnabled,
                      onChanged: (v) =>
                          appState.setNotificationsEnabled(v),
                      activeColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Data & Export
                _SectionHeader(title: 'Data & Export'),
                Container(
                  decoration: cardDecoration(),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.download_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        title: 'Export as CSV',
                        subtitle: 'Share your transactions',
                        onTap: () => _exportCsv(context),
                      ),
                      const Divider(height: 1, indent: 60),
                      _SettingsTile(
                        icon: Icons.table_chart_rounded,
                        iconColor: const Color(0xFF059669),
                        title: 'Export as Excel',
                        subtitle: 'Export as .xlsx file',
                        onTap: () => _exportXlsx(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Danger zone
                _SectionHeader(title: 'Danger Zone'),
                Container(
                  decoration: cardDecoration(),
                  child: _SettingsTile(
                    icon: Icons.refresh_rounded,
                    iconColor: AppColors.expense,
                    title: 'Reset App',
                    subtitle: 'Clear all data and restart onboarding',
                    titleColor: AppColors.expense,
                    onTap: () => _showResetDialog(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // About
                Center(
                  child: Text(
                    'FlowMoney v1.0.0\nBuilt with Flutter ❤️',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        height: 1.6),
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    final txVm = context.read<TransactionViewModel>();
    await ExportService().exportCsv(txVm.transactions, txVm.categories);
  }

  Future<void> _exportXlsx(BuildContext context) async {
    final txVm = context.read<TransactionViewModel>();
    await ExportService().exportXlsx(txVm.transactions, txVm.categories);
  }

  void _showThemePicker(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Choose Theme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          for (final mode in ThemeMode.values)
            ListTile(
              title: Text(_themeLabel(mode)),
              trailing: appState.themeMode == mode
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                appState.setThemeMode(mode);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, AppState appState) {
    const currencies = [
      'USD', 'EUR', 'GBP', 'KWD', 'AED', 'SAR', 'INR', 'JPY', 'CAD', 'AUD',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Choose Currency',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          ...currencies.map((c) => ListTile(
                title: Text(c),
                trailing: appState.currency == c
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  appState.setCurrency(c);
                  Navigator.pop(ctx);
                },
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text(
            'This will delete ALL your transactions, budgets, and patterns. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await DatabaseService().clearAll();
      await DataSeeder.seedIfNeeded(DatabaseService());
      await context.read<AppState>().resetApp();
    }
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return 'System Default';
      case ThemeMode.light: return 'Light';
      case ThemeMode.dark: return 'Dark';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.xs, bottom: AppSpacing.sm, top: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
            letterSpacing: 1),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: titleColor ?? AppColors.textPrimary)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary)
              : null),
    );
  }
}
