import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddSubscriptionScreen extends StatelessWidget {
  final String? categoryId;
  const AddSubscriptionScreen({super.key, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Subscription')),
      body: Center(
        child: Column(
          children: [
            Text('Add Sub (Cat: $categoryId)'),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
