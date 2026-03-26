// coverage:ignore-file

import 'package:leithmail/core/logging/app_logger.dart';

class AppLoggerNoOp implements AppLogger {
  const AppLoggerNoOp();
  @override
  void debug(String message, [Object? context]) {}
  @override
  void info(String message, [Object? context]) {}
  @override
  void warning(String message, [Object? context, StackTrace? st]) {}
  @override
  void error(String message, [Object? context, StackTrace? st]) {}
}
