import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

@immutable
class SettingsState {
  final ThemeMode themeMode;
  final String currencyCode;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.currencyCode = 'GBP',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? currencyCode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currencyCode: currencyCode ?? this.currencyCode,
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

    return SettingsState(themeMode: mode, currencyCode: currency);
  }

  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _box.put('theme_mode', isDark ? 'dark' : 'light');
    // Optimistic update
    state = AsyncData(state.value!.copyWith(themeMode: newMode));
  }

  Future<void> setCurrency(String code) async {
    await _box.put('currency', code);
    state = AsyncData(state.value!.copyWith(currencyCode: code));
  }

  Future<void> wipeData() async {
    await _box.clear();

    // Clear subscriptions
    if (Hive.isBoxOpen('subscriptions')) {
      await Hive.box('subscriptions').clear();
    } else {
      final subBox = await Hive.openBox('subscriptions');
      await subBox.clear();
    }

    // Reset local state to default
    state = const AsyncData(SettingsState());
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsState>(() {
  return SettingsController();
});
