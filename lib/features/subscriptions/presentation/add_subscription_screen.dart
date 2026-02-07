import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';
import 'package:uuid/uuid.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  const AddSubscriptionScreen({super.key, this.categoryId});

  @override
  ConsumerState<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _costController = TextEditingController();

  // State
  BillingCycle _cycle = BillingCycle.monthly;
  DateTime _firstBillDate = DateTime.now();
  late SubCategory _category;
  Color _color = Colors.blue; // Default or random

  @override
  void initState() {
    super.initState();
    // Initialize Category from param or default
    if (widget.categoryId != null) {
      try {
        _category = SubCategory.values.byName(widget.categoryId!);
      } catch (_) {
        _category = SubCategory.other;
      }
    } else {
      _category = SubCategory.entertainment;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final cost = double.parse(_costController.text.trim());

      final sub = Subscription(
        id: const Uuid().v4(),
        name: name,
        cost: cost,
        cycle: _cycle,
        firstBillDate: _firstBillDate,
        category: _category,
        colorHex:
            '#${_color.value.toRadixString(16).substring(2)}', // ARGB to RGB
        status: SubStatus.active,
        isTrial: false,
        paymentSource: null, cancellationUrl: null,
        trialEndDate: null, contractEndDate: null, notes: null,
        nextBillOverride: null,
      );

      await ref
          .read(subscriptionControllerProvider.notifier)
          .addSubscription(sub);

      if (mounted) {
        context.pop();
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _firstBillDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _firstBillDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for loading state
    final asyncState = ref.watch(subscriptionControllerProvider);
    final isLoading = asyncState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subscription'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              key: const Key('name_input'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subscription Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),

            // Cost
            TextFormField(
              key: const Key('cost_input'),
              controller: _costController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cost',
                prefixText: '£',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid Number';
                return null;
              },
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),

            // Cycle Chips
            Text('Billing Cycle',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: BillingCycle.values.map((c) {
                final isSelected = _cycle == c;
                return ChoiceChip(
                  label: Text(c.name.substring(0, 1).toUpperCase() +
                      c.name.substring(1)),
                  selected: isSelected,
                  onSelected: (sel) {
                    if (sel) setState(() => _cycle = c);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<SubCategory>(
              key: const Key('category_input'),
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: SubCategory.values.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.name.toUpperCase()),
                );
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (v) {
                      if (v != null) setState(() => _category = v);
                    },
            ),
            const SizedBox(height: 16),

            // Date Picker (First Bill)
            ListTile(
              title: const Text('First Bill Date'),
              subtitle: Text(DateFormat.yMMMd().format(_firstBillDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: isLoading ? null : _pickDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : _save,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.check),
      ),
    );
  }
}
