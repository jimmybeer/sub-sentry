import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sub_sentry/l10n/generated/app_localizations.dart';
import 'app_error.dart';

enum ErrorRecoveryAction { none, retry, fallback }

class ErrorHandler {
  static void log(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('--- ERROR LOG ---');
      print('Error: $error');
      if (stackTrace != null) print('Stacktrace: $stackTrace');
      print('-----------------');
    }

    // Always capture in Sentry (Sentry handles internal filters for debug/release if configured)
    Sentry.captureException(error, stackTrace: stackTrace);
  }

  static String getMessage(BuildContext context, dynamic error) {
    final l10n = AppLocalizations.of(context)!;

    if (error is StorageError) return l10n.errorStorage;
    if (error is PermissionError) return l10n.errorPermission;
    if (error is NetworkError) return l10n.errorNetwork;
    if (error is ValidationError) return l10n.errorValidation;

    return l10n.errorUnexpected;
  }

  static ErrorRecoveryAction getRecoveryAction(dynamic error) {
    if (error is NetworkError) return ErrorRecoveryAction.retry;
    if (error is StorageError) return ErrorRecoveryAction.retry;
    return ErrorRecoveryAction.none;
  }

  static void handleError(BuildContext context, dynamic error,
      {StackTrace? stackTrace, VoidCallback? onRetry}) {
    log(error, stackTrace);

    // In a real app, you might show a SnackBar or Dialog here
    // For now, this is just a central logic point
  }
}
