// coverage:ignore-file

import 'package:leithmail/core/logging/app_logger.dart';
import 'package:leithmail/core/logging/app_logger_no_op.dart';

class Log {
  Log._();

  static AppLogger _instance = AppLoggerNoOp();

  static AppLogger get instance => _instance;

  static void setLogger(AppLogger logger) {
    _instance = logger;
  }

  static void debug(String message, [Object? context]) =>
      _instance.debug(message, context);
  static void info(String message, [Object? context]) =>
      _instance.info(message, context);
  static void warning(String message, [Object? context, StackTrace? st]) =>
      _instance.warning(message, context, st);
  static void error(String message, [Object? context, StackTrace? st]) =>
      _instance.error(message, context, st);
}
