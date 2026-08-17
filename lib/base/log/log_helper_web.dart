import 'package:flutter/foundation.dart';

class Log {
  static void _write(String level, String message, Object? error) {
    if (kDebugMode) {
      debugPrint('[$level] $message${error == null ? '' : ' error=$error'}');
    }
  }

  static void trace(String message, {dynamic error, StackTrace? stackTrace}) =>
      _write('TRACE', message, error);
  static void debug(String message, {dynamic error, StackTrace? stackTrace}) =>
      _write('DEBUG', message, error);
  static void info(String message, {dynamic error, StackTrace? stackTrace}) =>
      _write('INFO', message, error);
  static void warn(String message, {dynamic error, StackTrace? stackTrace}) =>
      _write('WARN', message, error);
  static void error(String message, {dynamic error, StackTrace? stackTrace}) =>
      _write('ERROR', message, error);
  static void critical(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) => _write('CRITICAL', message, error);
  static void fatal(String message, {dynamic error, StackTrace? stackTrace}) =>
      _write('FATAL', message, error);

  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) => operation();

  static T measure<T>(String operationName, T Function() operation) =>
      operation();

  static void logMetrics() {}
}
