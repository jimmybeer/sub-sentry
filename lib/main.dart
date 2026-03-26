import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  // The DSN must be supplied at build time via:
  //   --dart-define=SENTRY_DSN=<value>
  // Never hardcode this value in source control.
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = kReleaseMode ? 0.1 : 1.0;
      },
      appRunner: _runApp,
    );
  } else {
    await _runApp();
  }
}

/// Retrieves the Hive encryption key from secure storage, creating and
/// persisting a new 32-byte random key if one does not already exist.
Future<HiveAesCipher> _hiveEncryptionCipher() async {
  const storage = FlutterSecureStorage();
  String? encoded = await storage.read(key: 'hive_key');
  if (encoded == null) {
    final rng = Random.secure();
    final keyBytes = Uint8List.fromList(
      List<int>.generate(32, (_) => rng.nextInt(256)),
    );
    encoded = base64UrlEncode(keyBytes);
    await storage.write(key: 'hive_key', value: encoded);
  }
  final keyBytes = base64Url.decode(encoded);
  return HiveAesCipher(keyBytes);
}

Future<void> _runApp() async {
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(SubscriptionModelAdapter());

    final cipher = await _hiveEncryptionCipher();
    final box = await Hive.openBox<SubscriptionModel>(
      'subscriptions',
      encryptionCipher: cipher,
    );
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
      final cipher = await _hiveEncryptionCipher();
      final box = await Hive.openBox<SubscriptionModel>(
        'subscriptions',
        encryptionCipher: cipher,
      );
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
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Something went wrong and the app could not start. Please reinstall the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
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
      error: (e, st) {
        ErrorHandler.log(e, st);
        return const MaterialApp(
          home: Scaffold(body: Center(child: Text('The app failed to load. Please restart.'))),
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
