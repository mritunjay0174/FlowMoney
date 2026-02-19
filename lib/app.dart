import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'design/app_theme.dart';
import 'viewmodels/app_state.dart';
import 'views/root_view.dart';

class FlowMoneyApp extends StatelessWidget {
  const FlowMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppState>().themeMode;

    return MaterialApp(
      title: 'FlowMoney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.light, // Use light theme for now; dark theme TBD
      themeMode: themeMode,
      home: const RootView(),
    );
  }
}
