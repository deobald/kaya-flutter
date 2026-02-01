import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

enum ErrorSeverity { warning, error }

/// Represents an application error or warning that should be displayed to the user.
@freezed
class AppError with _$AppError {
  const factory AppError({
    required String id,
    required String message,
    required ErrorSeverity severity,
    required DateTime timestamp,
    String? details,
  }) = _AppError;

  factory AppError.error({
    required String message,
    String? details,
  }) {
    return AppError(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: message,
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      details: details,
    );
  }

  factory AppError.warning({
    required String message,
    String? details,
  }) {
    return AppError(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: message,
      severity: ErrorSeverity.warning,
      timestamp: DateTime.now(),
      details: details,
    );
  }
}
