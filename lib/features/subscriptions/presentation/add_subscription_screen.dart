import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sub_sentry/features/settings/presentation/providers/settings_controller.dart';
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
          // Snapshot conditions before the add mutates state.
          final currentCount =
              ref.read(subscriptionControllerProvider).valueOrNull?.length ?? 0;
          final settings = ref.read(settingsControllerProvider).valueOrNull;
          final shouldPrompt = currentCount + 1 == 5 &&
              settings != null &&
              !settings.hasBeenPromptedForReview;

          ref
              .read(subscriptionControllerProvider.notifier)
              .addSubscription(sub);

          if (shouldPrompt) {
            // Mark first — prevents a second trigger if the user adds quickly.
            ref.read(settingsControllerProvider.notifier).markReviewPrompted();
            // Delay lets the screen pop and the dashboard settle before the
            // native overlay appears.
            Future.delayed(const Duration(milliseconds: 800), () async {
              final review = InAppReview.instance;
              final available = await review.isAvailable();
              if (available) await review.requestReview();
            });
          }

          context.pop();
        },
      ),
    );
  }
}
