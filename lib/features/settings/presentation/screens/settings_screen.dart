import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../subscriptions/domain/subscription.dart';
import '../../../subscriptions/presentation/providers/subscription_controller.dart';
import '../../../../core/constants/category_colors.dart';
import '../../../notifications/providers/notification_provider.dart';
import '../providers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (settings) => ListView(
          children: [
            // Theme Mode
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Theme Mode'),
              subtitle: Text(_themeModeName(settings.themeMode)),
              trailing: Switch(
                value: settings.themeMode == ThemeMode.dark,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .toggleTheme(val);
                },
              ),
            ),
            const Divider(),

            // Currency
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency'),
              trailing: DropdownButton<String>(
                value: settings.currencyCode,
                underline: const SizedBox(),
                items: ['GBP', 'USD', 'EUR']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setCurrency(val);
                  }
                },
              ),
            ),
            const Divider(),

            // Pay Days
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Pay Days'),
              subtitle: Text(settings.payDays.isEmpty
                  ? 'None set'
                  : settings.payDays.map((d) => _ordinal(d)).join(', ')),
              onTap: () => _showPayDayPicker(context, ref, settings.payDays),
            ),
            const Divider(),

            // Auto Shift Weekend Payments
            ListTile(
              leading: const Icon(Icons.calendar_view_week),
              title: const Text('Auto-Shift Weekend Payments'),
              subtitle: const Text('Move Sat/Sun payments to Monday'),
              trailing: Switch(
                value: settings.autoShiftWeekendPayments,
                onChanged: (val) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .toggleAutoShiftWeekendPayments(val);
                },
              ),
            ),
            const Divider(),

            // Generate Test Data (Development Helper)
            ListTile(
              leading: const Icon(Icons.science, color: Colors.blue),
              title: const Text('Generate Test Data',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
              subtitle:
                  const Text('Create 5-20 random subscriptions for testing'),
              onTap: () => _generateTestData(context, ref),
            ),
            const Divider(),

            // Notification Permission
            const NotificationPermissionTile(),
            const Divider(),

            // Test Notification (Development Helper)
            ListTile(
              leading:
                  const Icon(Icons.notifications_active, color: Colors.orange),
              title: const Text('Test Notification',
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold)),
              subtitle: const Text('Trigger an immediate notification'),
              onTap: () => _triggerTestNotification(context, ref),
            ),
            const Divider(),

            // Wipe Data (Danger Zone)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Wipe Data',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: const Text('Delete all subscriptions and reset app'),
              onTap: () => _confirmWipe(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  String _themeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _confirmWipe(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Data Wipe'),
        content: const Text(
            'Are you sure you want to delete all data? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                // Close dialog first
                Navigator.pop(ctx);

                // Show loading indicator
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Wiping data...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }

                // Perform wipe
                await ref.read(settingsControllerProvider.notifier).wipeData();

                // Invalidate subscription provider to force refresh
                ref.invalidate(subscriptionControllerProvider);

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data wiped successfully')),
                  );
                }
              } catch (e) {
                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error wiping data: $e')),
                  );
                }
              }
            },
            child: const Text('Wipe Everything'),
          ),
        ],
      ),
    );
  }

  String _ordinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  void _showPayDayPicker(
      BuildContext context, WidgetRef ref, List<int> currentDays) {
    final selected = Set<int>.from(currentDays);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Pay Days'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(31, (index) {
                    final day = index + 1;
                    final isSelected = selected.contains(day);
                    return FilterChip(
                      label: Text(day.toString()),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            selected.add(day);
                          } else {
                            selected.remove(day);
                          }
                        });
                      },
                    );
                  }),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final sorted = selected.toList()..sort();
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setPayDays(sorted);
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _generateTestData(BuildContext context, WidgetRef ref) async {
    final random = DateTime.now().millisecondsSinceEpoch;
    final count = 5 + (random % 16); // Between 5 and 20

    final services = [
      ('Netflix', 15.99, SubCategory.entertainment),
      ('Spotify', 9.99, SubCategory.entertainment),
      ('Amazon Prime', 8.99, SubCategory.entertainment),
      ('Disney+', 7.99, SubCategory.entertainment),
      ('Apple Music', 10.99, SubCategory.entertainment),
      ('YouTube Premium', 11.99, SubCategory.entertainment),
      ('Adobe Creative Cloud', 52.99, SubCategory.software),
      ('Microsoft 365', 6.99, SubCategory.software),
      ('GitHub Pro', 4.00, SubCategory.software),
      ('Dropbox Plus', 11.99, SubCategory.software),
      ('Notion', 8.00, SubCategory.software),
      ('ChatGPT Plus', 20.00, SubCategory.software),
      ('Gym Membership', 35.00, SubCategory.gym),
      ('Planet Fitness', 24.99, SubCategory.gym),
      ('Electricity', 85.00, SubCategory.utilities),
      ('Gas', 45.00, SubCategory.utilities),
      ('Internet', 50.00, SubCategory.utilities),
      ('Mobile Phone', 25.00, SubCategory.utilities),
      ('iCloud Storage', 2.99, SubCategory.other),
      ('VPN Service', 12.99, SubCategory.software),
    ];

    final cycles = [
      BillingCycle.weekly,
      BillingCycle.monthly,
      BillingCycle.monthly,
      BillingCycle.monthly, // Make monthly more common
      BillingCycle.quarterly,
      BillingCycle.yearly,
    ];

    try {
      final controller = ref.read(subscriptionControllerProvider.notifier);
      final now = DateTime.now();

      for (int i = 0; i < count; i++) {
        final serviceIndex = (random + i) % services.length;
        final service = services[serviceIndex];
        final cycleIndex = (random + i * 3) % cycles.length;

        final subscription = Subscription(
          id: 'test_${now.millisecondsSinceEpoch}_$i',
          name: service.$1,
          cost: service.$2,
          cycle: cycles[cycleIndex],
          firstBillDate: now.subtract(Duration(days: (random + i) % 90)),
          category: service.$3,
          colorHex: _getCategoryColorHex(service.$3),
          status: SubStatus.active,
          isTrial: i == 0, // Make first one a trial
        );

        await controller.addSubscription(subscription);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generated $count test subscriptions!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating test data: $e')),
        );
      }
    }
  }

  String _getCategoryColorHex(SubCategory category) {
    // Use spec-compliant colors from CategoryColors
    final color = CategoryColors.getColor(category);
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _triggerTestNotification(BuildContext context, WidgetRef ref) async {
    try {
      final notificationService =
          await ref.read(notificationServiceProvider.future);

      await notificationService.showNotification(
        id: 999999,
        title: 'Test Notification',
        body: 'This is a test notification from SubSentry settings.',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification triggered!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error triggering notification: $e')),
        );
      }
    }
  }
}

class NotificationPermissionTile extends ConsumerStatefulWidget {
  const NotificationPermissionTile({super.key});

  @override
  ConsumerState<NotificationPermissionTile> createState() =>
      _NotificationPermissionTileState();
}

class _NotificationPermissionTileState
    extends ConsumerState<NotificationPermissionTile>
    with WidgetsBindingObserver {
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    try {
      final service = await ref.read(notificationServiceProvider.future);
      final enabled = await service.areNotificationsEnabled();
      if (mounted) setState(() => _isEnabled = enabled);
    } catch (e) {
      // Handle error cleanly
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications),
      title: const Text('Notifications'),
      subtitle: Text(_isEnabled ? 'Permitted' : 'Disabled'),
      trailing: Switch(
        value: _isEnabled,
        onChanged: (val) async {
          final service = await ref.read(notificationServiceProvider.future);
          if (val && !_isEnabled) {
            // User wants to enable
            final granted = await service.requestPermissions();
            if (!granted) {
              if (context.mounted) _showOpenSettingsDialog(context, service);
            }
            // Check again regardless
            _checkPermission();
          } else if (!val && _isEnabled) {
            // User wants to disable - must go to settings
            if (context.mounted) _showOpenSettingsDialog(context, service);
          }
        },
      ),
    );
  }

  void _showOpenSettingsDialog(BuildContext context, dynamic service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manage Permissions'),
        content: const Text(
            'To change notification permissions, please visit your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              service.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
