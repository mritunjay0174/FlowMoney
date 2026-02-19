import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'viewmodels/app_state.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'viewmodels/analytics_viewmodel.dart';
import 'viewmodels/budget_viewmodel.dart';
import 'viewmodels/onboarding_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init services
  final db = DatabaseService();
  final notifications = NotificationService();
  await notifications.init();

  // Load app state
  final appState = AppState();
  await appState.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        Provider<DatabaseService>.value(value: db),
        Provider<NotificationService>.value(value: notifications),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(db),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionViewModel(db),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsViewModel(db),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetViewModel(db, notifications),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OnboardingViewModel(db, appState),
        ),
      ],
      child: const FlowMoneyApp(),
    ),
  );
}
