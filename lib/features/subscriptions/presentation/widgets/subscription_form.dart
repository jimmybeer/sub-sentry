import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';
import 'package:sub_sentry/core/constants/category_colors.dart';
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
  Color _color = Colors.blue; // Will be overridden in initState
  late SubStatus _status;
  bool _isTrial = false;
  DateTime? _trialEndDate;
  DateTime? _contractEndDate;
  DateTime? _nextBillOverride;
  late TextEditingController _paymentSourceController;
  late TextEditingController _notesController;
  bool _ignoreWeekendShift = false;
  bool _includeInWeeklySummary = true;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;

    _nameController = TextEditingController(text: data?.name ?? '');
    _costController = TextEditingController(text: data?.cost.toString() ?? '');

    _cycle = data?.cycle ?? BillingCycle.monthly;
    // ... rest of init ...
    _firstBillDate = data?.firstBillDate ?? DateTime.now();
    _category =
        data?.category ?? widget.initialCategory ?? SubCategory.entertainment;

    // Set color from existing data or use category default
    if (data?.colorHex != null) {
      _color = _parseColorHex(data!.colorHex);
    } else {
      _color = CategoryColors.getColor(_category);
    }

    _status = data?.status ?? SubStatus.active;
    _isTrial = data?.isTrial ?? false;
    _trialEndDate = data?.trialEndDate;
    _contractEndDate = data?.contractEndDate;
    _nextBillOverride = data?.nextBillOverride;
    _paymentSourceController =
        TextEditingController(text: data?.paymentSource ?? '');
    _notesController = TextEditingController(text: data?.notes ?? '');
    _ignoreWeekendShift = data?.ignoreWeekendShift ?? false;
    _includeInWeeklySummary = data?.includeInWeeklySummary ?? true;
  }

  Color _parseColorHex(String hex) {
    try {
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return CategoryColors.getColor(_category);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _paymentSourceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    if (_formKey.currentState!.validate()) {
      if (_isTrial && _trialEndDate == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Please select a Trial End Date for trial subscriptions')),
          );
        }
        return;
      }

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
        isTrial: _isTrial,
        paymentSource: _paymentSourceController.text.trim().isEmpty
            ? null
            : _paymentSourceController.text.trim(),
        cancellationUrl: widget.initialData?.cancellationUrl,
        trialEndDate: _trialEndDate,
        contractEndDate: _contractEndDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        nextBillOverride: _nextBillOverride,
        ignoreWeekendShift: _ignoreWeekendShift,
        includeInWeeklySummary: _includeInWeeklySummary,
      );

      widget.onSave(sub);
    }
  }

  Future<void> _selectDate(
      DateTime? initial, ValueChanged<DateTime> onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onSelected(picked);
  }

  Future<void> _pickBillDate() async {
    final initialDate = _nextBillOverride ?? _firstBillDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (!mounted) return;

      if (widget.initialData == null) {
        setState(() => _firstBillDate = picked);
      } else {
        final choice = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Change Payment Date'),
            content: const Text(
                'Is this a one-off change for the next bill, or a permanent change to the billing cycle?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'one-off'),
                child: const Text('One-off'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'permanent'),
                child: const Text('Permanent'),
              ),
            ],
          ),
        );

        if (choice == 'permanent') {
          setState(() {
            _firstBillDate = picked;
            _nextBillOverride = null;
          });
        } else if (choice == 'one-off') {
          setState(() {
            _nextBillOverride = picked;
          });
        }
      }
    }
  }

  String _getPaymentDateDescription() {
    final date = _nextBillOverride ?? _firstBillDate;
    final isOneOff = _nextBillOverride != null;
    final isEdit = widget.initialData != null;

    if (isOneOff) {
      return '${DateFormat.yMMMd().format(date)} (One-off)';
    }

    if (isEdit) {
      switch (_cycle) {
        case BillingCycle.monthly:
          return 'Day ${date.day} of every month';
        case BillingCycle.weekly:
          return 'Every ${DateFormat('EEEE').format(date)}';
        case BillingCycle.yearly:
          return 'Every ${DateFormat('MMMM d').format(date)}';
        case BillingCycle.quarterly:
          return 'Day ${date.day} (Quarterly)';
      }
    }

    return DateFormat.yMMMd().format(date);
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
                  title: const Text('Payment Date'),
                  subtitle: Text(_getPaymentDateDescription()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickBillDate,
                ),
                const Divider(),

                SwitchListTile(
                  title: const Text('Exact Date Only'),
                  subtitle: const Text(
                      'Do not shift payments that fall on weekends or missing month days'),
                  value: _ignoreWeekendShift,
                  onChanged: (v) => setState(() => _ignoreWeekendShift = v),
                ),
                SwitchListTile(
                  title: const Text('Include in Weekly Summary'),
                  subtitle: const Text('Show in "Coming Up" notification'),
                  value: _includeInWeeklySummary,
                  onChanged: (v) => setState(() => _includeInWeeklySummary = v),
                ),
                const Divider(),

                // Is Trial / Trial End Date
                SwitchListTile(
                  title: const Text('Is Trial?'),
                  value: _isTrial,
                  onChanged: (v) => setState(() => _isTrial = v),
                ),
                if (_isTrial)
                  ListTile(
                    title: const Text('Trial End Date'),
                    subtitle: Text(_trialEndDate == null
                        ? 'Select Date'
                        : DateFormat.yMMMd().format(_trialEndDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(_trialEndDate, (d) {
                      setState(() {
                        _trialEndDate = d;
                        _firstBillDate = d;
                      });
                    }),
                  ),

                // Contract End Date
                ListTile(
                  title: const Text('Contract End Date'),
                  subtitle: Text(_contractEndDate == null
                      ? 'None'
                      : DateFormat.yMMMd().format(_contractEndDate!)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_contractEndDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              setState(() => _contractEndDate = null),
                        ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                  onTap: () => _selectDate(_contractEndDate,
                      (d) => setState(() => _contractEndDate = d)),
                ),
                const SizedBox(height: 16),

                // Payment Source
                TextFormField(
                  key: const Key('payment_source_input'),
                  controller: _paymentSourceController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Source',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Status
                DropdownButtonFormField<SubStatus>(
                  key: const Key('status_input'),
                  value: _status,
                  decoration: const InputDecoration(
                      labelText: 'Status', border: OutlineInputBorder()),
                  items: SubStatus.values.map((s) {
                    return DropdownMenuItem(
                        value: s, child: Text(s.name.toUpperCase()));
                  }).toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  key: const Key('notes_input'),
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
