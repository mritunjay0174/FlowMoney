import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_state.dart';
import 'onboarding/onboarding_page.dart';
import 'main_scaffold.dart';

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return appState.onboardingComplete
        ? const MainScaffold()
        : const OnboardingPage();
  }
}
