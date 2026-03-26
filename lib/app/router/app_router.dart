import 'package:flutter/foundation.dart';
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
  // Only watch hasSeenOnboarding to trigger redirect when it changes.
  // We don't watch the whole settings provider to avoid recreating the router
  // on every setting change (which would close the settings screen).
  final hasSeenOnboarding = ref.watch(
    settingsControllerProvider.select((s) => s.valueOrNull?.hasSeenOnboarding),
  );

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      // If settings are loading, don't redirect yet
      if (hasSeenOnboarding == null) return null;

      final onOnboarding = state.uri.path == '/onboarding';
      final seen = hasSeenOnboarding;

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
