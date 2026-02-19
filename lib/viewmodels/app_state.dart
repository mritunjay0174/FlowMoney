import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AppState extends ChangeNotifier {
  static const _keyOnboarding = 'onboarding_complete';
  static const _keyCurrency = 'currency_code';
  static const _keyTheme = 'theme_mode';
  static const _keyNotifications = 'notifications_enabled';

  bool _onboardingComplete = false;
  String _currency = 'USD';
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;

  bool get onboardingComplete => _onboardingComplete;
  String get currency => _currency;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;

  String get currencySymbol {
    try {
      return NumberFormat.simpleCurrency(name: _currency).currencySymbol;
    } catch (_) {
      return _currency;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingComplete = prefs.getBool(_keyOnboarding) ?? false;
    _currency = prefs.getString(_keyCurrency) ?? _detectCurrency();
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    final themeIndex = prefs.getInt(_keyTheme) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  String _detectCurrency() {
    final locale = PlatformDispatcher.instance.locale;
    try {
      final fmt = NumberFormat.simpleCurrency(locale: locale.toString());
      return fmt.currencyName ?? 'USD';
    } catch (_) {
      return 'USD';
    }
  }

  Future<void> completeOnboarding({required String currency}) async {
    _onboardingComplete = true;
    _currency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
    await prefs.setString(_keyCurrency, currency);
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    _currency = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, code);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
    notifyListeners();
  }

  Future<void> resetApp() async {
    _onboardingComplete = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
