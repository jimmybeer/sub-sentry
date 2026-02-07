import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/features/settings/presentation/providers/settings_controller.dart';
import 'package:sub_sentry/features/settings/presentation/screens/settings_screen.dart';

class FakeSettingsController extends SettingsController {
  @override
  Future<SettingsState> build() async {
    return const SettingsState(themeMode: ThemeMode.dark, currencyCode: 'GBP');
  }

  @override
  Future<void> toggleTheme(bool isDark) async {}

  @override
  Future<void> setCurrency(String code) async {}

  @override
  Future<void> wipeData() async {}
}

void main() {
  testWidgets('Settings Screen displays theme, currency, and wipe data option',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider
              .overrideWith(() => FakeSettingsController()),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Theme Control
    expect(find.text('Theme Mode'), findsOneWidget);

    // Verify Currency Control
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('GBP'), findsOneWidget); // Matches Default in Fake

    // Verify Wipe Data Button
    expect(find.text('Wipe Data'), findsWidgets);
  });
}
