import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../subscriptions/data/model/subscription_model.dart';

@immutable
class SettingsState {
  final ThemeMode themeMode;
  final String currencyCode;
  final bool hasSeenOnboarding;
  final List<int> payDays;
  final bool autoShiftWeekendPayments;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.currencyCode = 'GBP',
    this.hasSeenOnboarding = false,
    this.payDays = const [],
    this.autoShiftWeekendPayments = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? currencyCode,
    bool? hasSeenOnboarding,
    List<int>? payDays,
    bool? autoShiftWeekendPayments,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currencyCode: currencyCode ?? this.currencyCode,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      payDays: payDays ?? this.payDays,
      autoShiftWeekendPayments:
          autoShiftWeekendPayments ?? this.autoShiftWeekendPayments,
    );
  }
}

class SettingsController extends AsyncNotifier<SettingsState> {
  late Box _box;

  @override
  Future<SettingsState> build() async {
    _box = await Hive.openBox('settings');

    final modeStr = _box.get('theme_mode', defaultValue: 'system');
    ThemeMode mode = ThemeMode.system;
    if (modeStr == 'light') mode = ThemeMode.light;
    if (modeStr == 'dark') mode = ThemeMode.dark;

    final currency = _box.get('currency', defaultValue: 'GBP');
    final seenOnboarding = _box.get('onboarding_complete', defaultValue: false);
    final payDays = _box.get('pay_days', defaultValue: <int>[]);
    final autoShift = _box.get('auto_shift_weekend', defaultValue: false);

    return SettingsState(
      themeMode: mode,
      currencyCode: currency,
      hasSeenOnboarding: seenOnboarding,
      payDays: List<int>.from(payDays),
      autoShiftWeekendPayments: autoShift,
    );
  }

  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _box.put('theme_mode', isDark ? 'dark' : 'light');
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(themeMode: newMode));
    }
  }

  Future<void> setCurrency(String code) async {
    await _box.put('currency', code);
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(currencyCode: code));
    }
  }

  Future<void> setPayDays(List<int> days) async {
    await _box.put('pay_days', days);
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(payDays: days));
    }
  }

  Future<void> toggleAutoShiftWeekendPayments(bool value) async {
    await _box.put('auto_shift_weekend', value);
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(autoShiftWeekendPayments: value));
    }
  }

  Future<void> completeOnboarding() async {
    await _box.put('onboarding_complete', true);
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(hasSeenOnboarding: true));
    }
  }

  Future<void> wipeData() async {
    await _box.clear();

    // Use typed box to match how it was opened in main.dart
    if (Hive.isBoxOpen('subscriptions')) {
      final subBox = Hive.box<SubscriptionModel>('subscriptions');
      await subBox.clear();
    }

    state = const AsyncData(SettingsState());
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsState>(() {
  return SettingsController();
});
