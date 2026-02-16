import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sub_sentry/features/settings/presentation/providers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _getDayName(int day) {
    // 1 = Mon, 7 = Sun
    switch (day) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, int currentDay,
      String currentTimeStr) async {
    final parts = currentTimeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );

    if (picked != null) {
      final newTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref
          .read(settingsControllerProvider.notifier)
          .setWeeklySummaryTime(currentDay, newTime);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Notifications',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              SwitchListTile(
                title: const Text('Weekly Summary'),
                subtitle: const Text('Get a summary of upcoming bills'),
                value: settings.weeklySummaryEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .toggleWeeklySummary(val);
                },
              ),
              if (settings.weeklySummaryEnabled) ...[
                ListTile(
                  title: const Text('Day of Week'),
                  trailing: DropdownButton<int>(
                    value: settings.weeklySummaryDay,
                    underline: const SizedBox(),
                    items: List.generate(7, (index) {
                      final day = index + 1;
                      return DropdownMenuItem(
                          value: day, child: Text(_getDayName(day)));
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .setWeeklySummaryTime(
                                val, settings.weeklySummaryTime);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Time'),
                  subtitle: Text(settings.weeklySummaryTime),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _pickTime(context, ref,
                      settings.weeklySummaryDay, settings.weeklySummaryTime),
                ),
              ],
              const Divider(),
              SwitchListTile(
                title: const Text('Trial Alerts'),
                subtitle:
                    const Text('Get notified before trials end (5d, 3d, 1d)'),
                value: settings.trialAlertsEnabled,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .toggleTrialAlerts(val);
                },
              ),
              const Divider(),
              // Existing Settings
              SwitchListTile(
                title: const Text('Weekend Auto-Shift'),
                subtitle:
                    const Text('Move weekend payments to Monday automatically'),
                value: settings.autoShiftWeekendPayments,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .toggleAutoShiftWeekendPayments(val);
                },
              ),
              ListTile(
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                        value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(
                        value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(
                        value: ThemeMode.dark, child: Text('Dark')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .toggleTheme(val == ThemeMode.dark);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Currency'),
                trailing: DropdownButton<String>(
                  value: settings.currencyCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                    DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setCurrency(val);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Reset Data'),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset Data?'),
                      content: const Text(
                          'This will delete all subscriptions and settings.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Reset',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(settingsControllerProvider.notifier).wipeData();
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
