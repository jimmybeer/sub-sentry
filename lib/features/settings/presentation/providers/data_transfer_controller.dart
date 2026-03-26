import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:sub_sentry/features/subscriptions/presentation/providers/subscription_controller.dart';
import 'package:sub_sentry/features/settings/data/data_transfer_service.dart';

class DataTransferController {
  final Ref _ref;
  final DataTransferService _service = DataTransferService();

  DataTransferController(this._ref);

  Future<String?> exportData() async {
    try {
      final subscriptions =
          _ref.read(subscriptionControllerProvider).valueOrNull ?? [];
      final csvContent = _service.exportToCsv(subscriptions);

      final String fileName =
          'subsentry_export_${DateTime.now().millisecondsSinceEpoch}.csv';

      // Use a temporary directory to store the file before sharing
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/$fileName');
      await tempFile.writeAsString(csvContent);

      // shareXFiles opens the system share sheet, allowing the user to
      // "Save to Files", "Send to Drive", email, etc.
      final result = await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: 'SubSentry Subscriptions Export',
        text: 'My subscription data export from SubSentry.',
      );

      // On some platforms (like mobile), we can't easily get the final saved path
      // from Share, but we return a success indicator if the user shared it.
      if (result.status == ShareResultStatus.success) {
        return 'Export shared/saved successfully';
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Import file is too large (max 5 MB)');
        }

        final content = await file.readAsString();
        final parsed = _service.importFromCsv(content);
        final subscriptions =
            parsed.map((sub) => sub.copyWith(id: const Uuid().v4())).toList();

        if (subscriptions.isNotEmpty) {
          final controller = _ref.read(subscriptionControllerProvider.notifier);
          await controller.importSubscriptions(subscriptions);
          return subscriptions.length;
        }
      }
      return 0;
    } catch (e) {
      rethrow;
    }
  }
}

final dataTransferControllerProvider =
    Provider((ref) => DataTransferController(ref));
