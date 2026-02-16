sealed class AppError implements Exception {
  final String? message;
  final dynamic originalError;

  const AppError({this.message, this.originalError});
}

class StorageError extends AppError {
  const StorageError({super.message, super.originalError});
}

class PermissionError extends AppError {
  const PermissionError({super.message, super.originalError});
}

class NetworkError extends AppError {
  const NetworkError({super.message, super.originalError});
}

class ValidationError extends AppError {
  const ValidationError({super.message, super.originalError});
}

class UnexpectedError extends AppError {
  const UnexpectedError({super.message, super.originalError});
}
