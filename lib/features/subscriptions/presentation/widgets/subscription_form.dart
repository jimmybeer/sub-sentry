import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:uuid/uuid.dart';

class SubscriptionForm extends StatefulWidget {
  final Subscription? initialData;
  final SubCategory? initialCategory;
  final ValueChanged<Subscription> onSave;
  final VoidCallback? onDelete;

  const SubscriptionForm({
    super.key,
    this.initialData,
    this.initialCategory,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends State<SubscriptionForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _costController;

  late BillingCycle _cycle;
  late DateTime _firstBillDate;
  late SubCategory _category;
  Color _color = Colors.blue;
  late SubStatus _status;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;

    _nameController = TextEditingController(text: data?.name ?? '');
    _costController = TextEditingController(text: data?.cost.toString() ?? '');

    _cycle = data?.cycle ?? BillingCycle.monthly;
    _firstBillDate = data?.firstBillDate ?? DateTime.now();
    _category =
        data?.category ?? widget.initialCategory ?? SubCategory.entertainment;

    _status = data?.status ?? SubStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final id = widget.initialData?.id ?? const Uuid().v4();
      final name = _nameController.text.trim();
      final cost = double.parse(_costController.text.trim());

      final sub = Subscription(
        id: id,
        name: name,
        cost: cost,
        cycle: _cycle,
        firstBillDate: _firstBillDate,
        category: _category,
        colorHex: '#${_color.value.toRadixString(16)}',
        status: _status,
        isTrial: widget.initialData?.isTrial ?? false,
        paymentSource: widget.initialData?.paymentSource,
        cancellationUrl: widget.initialData?.cancellationUrl,
        trialEndDate: widget.initialData?.trialEndDate,
        contractEndDate: widget.initialData?.contractEndDate,
        notes: widget.initialData?.notes,
        nextBillOverride: widget.initialData?.nextBillOverride,
      );

      widget.onSave(sub);
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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
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
                ),
                const SizedBox(height: 16),

                // Cycle
                Text('Billing Cycle',
                    style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: BillingCycle.values.map((c) {
                    return ChoiceChip(
                      label: Text(c.name),
                      selected: _cycle == c,
                      onSelected: (sel) {
                        if (sel) setState(() => _cycle = c);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<SubCategory>(
                  key: const Key('category_input'),
                  value: _category,
                  decoration: const InputDecoration(
                      labelText: 'Category', border: OutlineInputBorder()),
                  items: SubCategory.values.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.name));
                  }).toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),

                ListTile(
                  title: const Text('First Bill Date'),
                  subtitle: Text(DateFormat.yMMMd().format(_firstBillDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.onDelete != null)
                  IconButton(
                    key: const Key('delete_button'),
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                  )
                else
                  const SizedBox(),
                FloatingActionButton(
                  onPressed: _submit,
                  child: const Icon(Icons.check),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
