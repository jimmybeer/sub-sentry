import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditSubscriptionScreen extends StatelessWidget {
  final String id;
  const EditSubscriptionScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Subscription')),
      body: Center(
        child: Column(
          children: [
            Text('Edit Sub ID: $id'),
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
