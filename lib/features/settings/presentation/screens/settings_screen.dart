import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            onPressed: () {
              ref.read(settingsControllerProvider.notifier).wipeData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data wiped successfully')),
              );
            },
            child: const Text('Wipe Everything'),
          ),
        ],
      ),
    );
  }
}
