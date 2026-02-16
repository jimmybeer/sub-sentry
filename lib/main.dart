import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_controller.dart';
import 'features/subscriptions/data/model/subscription_model.dart';
import 'features/subscriptions/data/repository/hive_subscription_repository.dart';
import 'features/subscriptions/presentation/providers/subscription_controller.dart';
import 'shared/widgets/error_boundary.dart';
import 'shared/error_handling/error_handler.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://38f4aebc60bdbbbe0321d756476987ba@o4510866595053568.ingest.de.sentry.io/4510894655537232';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      try {
        await Hive.initFlutter();
        Hive.registerAdapter(SubscriptionModelAdapter());

        final box = await Hive.openBox<SubscriptionModel>('subscriptions');
        final repository = HiveSubscriptionRepository(box);

        runApp(SentryWidget(
          child: ProviderScope(
            overrides: [
              subscriptionRepositoryProvider.overrideWithValue(repository),
            ],
            child: const SubSentryApp(),
          ),
        ));
      } catch (e, stack) {
        ErrorHandler.log(e, stack);

        // Attempt Recovery: Delete corrupted box and retry
        try {
          await Hive.deleteBoxFromDisk('subscriptions');
          final box = await Hive.openBox<SubscriptionModel>('subscriptions');
          final repository = HiveSubscriptionRepository(box);

          runApp(SentryWidget(
            child: ProviderScope(
              overrides: [
                subscriptionRepositoryProvider.overrideWithValue(repository),
              ],
              child: const SubSentryApp(),
            ),
          ));
        } catch (e2, stack2) {
          ErrorHandler.log(e2, stack2);
          runApp(SentryWidget(
            child: MaterialApp(
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
            ),
          ));
        }
      }
    },
  );
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
      error: (e, st) {
        ErrorHandler.log(e, st);
        return MaterialApp(
          home: Scaffold(body: Center(child: Text('Initialization Error: $e'))),
          debugShowCheckedModeBanner: false,
        );
      },
      data: (settings) => AppErrorBoundary(
        child: MaterialApp.router(
          title: 'SubSentry',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}
