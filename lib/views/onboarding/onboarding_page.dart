import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import 'welcome_page.dart';
import 'currency_page.dart';
import 'recurring_expenses_page.dart';
import 'complete_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    // Keep PageView in sync with VM page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients &&
          _controller.page?.round() != vm.page) {
        _controller.animateToPage(
          vm.page,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          WelcomePage(),
          CurrencyPage(),
          RecurringExpensesPage(),
          CompletePage(),
        ],
      ),
    );
  }
}
