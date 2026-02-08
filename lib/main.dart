import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_controller.dart';
import 'features/subscriptions/data/model/subscription_model.dart';
import 'features/subscriptions/data/repository/hive_subscription_repository.dart';

import 'features/subscriptions/presentation/providers/subscription_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(SubscriptionModelAdapter());

    // Open Box
    final box = await Hive.openBox<SubscriptionModel>('subscriptions');
    final repository = HiveSubscriptionRepository(box);

    runApp(ProviderScope(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(repository),
      ],
      child: const SubSentryApp(),
    ));
  } catch (e, stack) {
    debugPrint('Initialization Error: $e');
    debugPrint(stack.toString());

    // Attempt Recovery: Delete corrupted box and retry
    try {
      debugPrint('Attempting to recover by deleting box...');
      await Hive.deleteBoxFromDisk('subscriptions');
      final box = await Hive.openBox<SubscriptionModel>('subscriptions');
      final repository = HiveSubscriptionRepository(box);

      runApp(ProviderScope(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(repository),
        ],
        child: const SubSentryApp(),
      ));
      return; // Return if recovery successful
    } catch (e2, stack2) {
      debugPrint('Recovery Failed: $e2');
      debugPrint(stack2.toString());
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Fatal Error: Failed to initialize app even after recovery.\n$e\n\nRecovery Error:\n$e2',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ));
    }
  }
}

class SubSentryApp extends ConsumerWidget {
  const SubSentryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      ),
      error: (e, st) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Initialization Error: $e'))),
        debugShowCheckedModeBanner: false,
      ),
      data: (settings) => MaterialApp.router(
        title: 'SubSentry',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
