// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errorStorage => 'A storage error occurred. Please try again.';

  @override
  String get errorPermission =>
      'Permission denied. Please check your settings.';

  @override
  String get errorNetwork =>
      'A network error occurred. Please check your connection.';

  @override
  String get errorValidation => 'Please check the entered information.';

  @override
  String get errorUnexpected => 'An unexpected error occurred.';

  @override
  String get errorRetry => 'Try Again';

  @override
  String get errorTitle => 'Oops!';
}
