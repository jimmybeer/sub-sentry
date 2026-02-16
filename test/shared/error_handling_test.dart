import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_sentry/shared/error_handling/app_error.dart';
import 'package:sub_sentry/shared/error_handling/error_handler.dart';
import 'package:sub_sentry/l10n/generated/app_localizations.dart';

void main() {
  group('AppError', () {
    test('StorageError should be an AppError', () {
      expect(const StorageError(), isA<AppError>());
    });

    test('NetworkError should be an AppError', () {
      expect(const NetworkError(), isA<AppError>());
    });
  });

  group('ErrorHandler', () {
    testWidgets('should map StorageError to correct message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final message =
                  ErrorHandler.getMessage(context, const StorageError());
              // This depends on the arb content
              expect(message, contains('storage error'));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should map NetworkError to correct message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final message =
                  ErrorHandler.getMessage(context, const NetworkError());
              expect(message, contains('network error'));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should map PermissionError to correct message',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final message =
                  ErrorHandler.getMessage(context, const PermissionError());
              expect(message, contains('Permission denied'));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should map ValidationError to correct message',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final message =
                  ErrorHandler.getMessage(context, const ValidationError());
              expect(message, contains('check the entered information'));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should map UnexpectedError to default message',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final message =
                  ErrorHandler.getMessage(context, 'Some random error');
              expect(message, contains('unexpected error'));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    test('getRecoveryAction returns retry for NetworkError', () {
      expect(ErrorHandler.getRecoveryAction(const NetworkError()),
          ErrorRecoveryAction.retry);
    });

    test('getRecoveryAction returns none for ValidationError', () {
      expect(ErrorHandler.getRecoveryAction(const ValidationError()),
          ErrorRecoveryAction.none);
    });
  });
}
