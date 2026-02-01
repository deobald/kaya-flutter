import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/core/services/logger_service.dart';
import 'package:kaya/features/errors/models/app_error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'error_service.g.dart';

/// Service to track and manage application errors.
/// Errors are kept in memory only (not persisted across restarts).
/// The log file preserves error history.
@Riverpod(keepAlive: true)
class ErrorService extends _$ErrorService {
  @override
  List<AppError> build() => [];

  void addError(String message, {String? details}) {
    final error = AppError.error(message: message, details: details);
    state = [...state, error];

    // Log the error
    ref.read(loggerProvider)?.e('Error: $message', details);
  }

  void addWarning(String message, {String? details}) {
    final warning = AppError.warning(message: message, details: details);
    state = [...state, warning];

    // Log the warning
    ref.read(loggerProvider)?.w('Warning: $message ${details ?? ''}');
  }

  void removeError(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

/// Provider for whether there are any active errors
@riverpod
bool hasErrors(Ref ref) {
  final errors = ref.watch(errorServiceProvider);
  return errors.isNotEmpty;
}

/// Provider for error count
@riverpod
int errorCount(Ref ref) {
  return ref.watch(errorServiceProvider).length;
}
