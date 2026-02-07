import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';
import 'package:sub_sentry/features/subscriptions/presentation/widgets/subscription_form.dart';

class AddSubscriptionScreen extends ConsumerWidget {
  final String? categoryId;
  const AddSubscriptionScreen({super.key, this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SubCategory? initialCategory;
    try {
      if (categoryId != null) {
        initialCategory = SubCategory.values.byName(categoryId!);
      }
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(title: const Text('Add Subscription')),
      body: SubscriptionForm(
        initialCategory: initialCategory,
        onSave: (sub) {
          ref
              .read(subscriptionControllerProvider.notifier)
              .addSubscription(sub);
          context.pop();
        },
      ),
    );
  }
}
