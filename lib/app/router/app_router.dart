import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/settings/presentation/providers/settings_controller.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subscriptions/presentation/add_subscription_screen.dart';
import '../../features/subscriptions/presentation/edit_subscription_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  // Watch settings to trigger rebuild on change
  final settingsAsync = ref.watch(settingsControllerProvider);

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final settings = settingsAsync.valueOrNull;

      // If settings are loading, don't redirect yet (or show splash)
      if (settings == null) return null;

      final onOnboarding = state.uri.path == '/onboarding';
      final seen = settings.hasSeenOnboarding;

      if (!seen && !onOnboarding) {
        return '/onboarding';
      }

      if (seen && onOnboarding) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'add',
            pageBuilder: (context, state) {
              final catId = state.uri.queryParameters['categoryId'];
              return MaterialPage(
                fullscreenDialog: true,
                child: AddSubscriptionScreen(categoryId: catId),
              );
            },
          ),
          GoRoute(
            path: 'edit/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return MaterialPage(
                fullscreenDialog: true,
                child: EditSubscriptionScreen(id: id),
              );
            },
          ),
        ],
      ),
    ],
  );
}
