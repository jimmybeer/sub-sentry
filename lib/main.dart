import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'features/subscriptions/data/model/subscription_model.dart';
import 'features/subscriptions/data/repository/hive_subscription_repository.dart';

import 'features/subscriptions/presentation/providers/subscription_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
}

class SubSentryApp extends ConsumerWidget {
  const SubSentryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'SubSentry',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
