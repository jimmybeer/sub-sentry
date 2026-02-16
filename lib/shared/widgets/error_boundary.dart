import 'package:flutter/material.dart';
import '../error_handling/error_handler.dart';

class AppErrorBoundary extends StatefulWidget {
  final Widget child;

  const AppErrorBoundary({super.key, required this.child});

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  dynamic _error;

  @override
  void initState() {
    super.initState();
    // Catch Flutter errors that happen during building
    ErrorWidget.builder = (details) {
      ErrorHandler.log(details.exception, details.stack);
      return _ErrorFallbackUI(
        error: details.exception,
        onRetry: () {
          setState(() {
            _error = null;
          });
        },
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorFallbackUI(
        error: _error,
        onRetry: () {
          setState(() {
            _error = null;
          });
        },
      );
    }

    return widget.child;
  }
}

class _ErrorFallbackUI extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;

  const _ErrorFallbackUI({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final message = ErrorHandler.getMessage(context, error);
    final recovery = ErrorHandler.getRecoveryAction(error);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Oops!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (recovery == ErrorRecoveryAction.retry) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
