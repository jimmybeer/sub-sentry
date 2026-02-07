import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';
import 'widgets/subscription_form.dart';

class EditSubscriptionScreen extends ConsumerWidget {
  final String id;
  const EditSubscriptionScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSubs = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Subscription'),
      ),
      body: asyncSubs.when(
        data: (subs) {
          // Find the subscription
          final sub = subs.cast<Subscription?>().firstWhere(
                (s) => s?.id == id,
                orElse: () => null,
              );

          if (sub == null) {
            return const Center(child: Text('Subscription not found'));
          }

          return SubscriptionForm(
            initialData: sub,
            onSave: (updatedSub) {
              ref
                  .read(subscriptionControllerProvider.notifier)
                  .updateSubscription(updatedSub);
              context.pop();
            },
            onDelete: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text(
                      'Are you sure you want to delete this subscription?'),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error),
                      onPressed: () {
                        ref
                            .read(subscriptionControllerProvider.notifier)
                            .deleteSubscription(id);
                        // Pop dialog
                        context.pop();
                        // Pop screen
                        context.pop();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
