import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_sentry/features/onboarding/presentation/onboarding_screen.dart';
import 'package:sub_sentry/features/settings/presentation/providers/settings_controller.dart';

class MockSettingsController extends SettingsController {
  bool completed = false;

  @override
  Future<SettingsState> build() async => const SettingsState();

  @override
  Future<void> completeOnboarding() async {
    completed = true;
    state = AsyncData(state.value!.copyWith(hasSeenOnboarding: true));
  }
}

void main() {
  testWidgets('Onboarding screen displays content and completes when tapped',
      (tester) async {
    final mockController = MockSettingsController();

    // Use GoRouter to emulate nav context or just MaterialApp if button uses context.go
    // OnboardingScreen uses context.go('/home').
    // context.go requires GoRouter in tree.

    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
            path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
        GoRoute(
            path: '/home',
            builder: (_, __) => const Scaffold(body: Text('Home'))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(() => mockController),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Intro Page
    expect(find.text('Welcome to SubSentry'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // 2. Verify Currency Page
    expect(find.text('Select Currency'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // 3. Verify Notifications Page
    expect(find.text('Stay Updated'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // 4. Verify Ready Page and Tap Get Started
    expect(find.text("You're All Set!"), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // 4. Verify Logic
    expect(mockController.completed, true);

    // 5. Verify Navigated to Home
    expect(find.text('Home'), findsOneWidget);
  });
}
