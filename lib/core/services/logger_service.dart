import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger_service.g.dart';

/// A file output for the logger that writes to both console and file.
class FileLogOutput extends LogOutput {
  File? _logFile;
  IOSink? _sink;

  FileLogOutput();

  @override
  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    final logDir = Directory('${dir.path}/kaya/logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    _logFile = File('${logDir.path}/kaya.log');
    _sink = _logFile!.openWrite(mode: FileMode.append);
  }

  @override
  void output(OutputEvent event) {
    // Always print to console
    for (final line in event.lines) {
      // ignore: avoid_print
      print(line);
    }

    // Write to file if initialized
    if (_sink != null) {
      for (final line in event.lines) {
        _sink!.writeln(line);
      }
    }
  }

  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
  }

  Future<String> readLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return '';
    }
    await _sink?.flush();
    return await _logFile!.readAsString();
  }

  Future<File?> getLogFile() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return null;
    }
    return _logFile;
  }

  Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _sink?.close();
      await _logFile!.writeAsString('');
      _sink = _logFile!.openWrite(mode: FileMode.append);
    }
  }
}

/// Application logger service that writes to both console and file.
class LoggerService {
  final Logger _logger;
  final FileLogOutput _fileOutput;

  LoggerService._(this._logger, this._fileOutput);

  static Future<LoggerService> create() async {
    final fileOutput = FileLogOutput();
    await fileOutput.init();

    final logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      output: fileOutput,
    );

    return LoggerService._(logger, fileOutput);
  }

  void d(String message) => _logger.d(message);
  void i(String message) => _logger.i(message);
  void w(String message) => _logger.w(message);
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  Future<String> readLogs() => _fileOutput.readLogs();
  Future<File?> getLogFile() => _fileOutput.getLogFile();
  Future<void> clearLogs() => _fileOutput.clearLogs();
  Future<void> dispose() => _fileOutput.dispose();
}

@Riverpod(keepAlive: true)
Future<LoggerService> loggerService(Ref ref) async {
  final service = await LoggerService.create();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Convenience provider for synchronous logger access after initialization
@Riverpod(keepAlive: true)
LoggerService? logger(Ref ref) {
  final asyncValue = ref.watch(loggerServiceProvider);
  return asyncValue.valueOrNull;
}
