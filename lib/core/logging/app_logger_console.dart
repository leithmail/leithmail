// ignore_for_file: avoid_print
// coverage:ignore-file

import 'package:leithmail/core/logging/app_logger.dart';

class AppLoggerConsole implements AppLogger {
  const AppLoggerConsole();

  static const _reset = '\x1B[0m';
  static const _gray = '\x1B[90m';
  static const _cyan = '\x1B[36m';
  static const _yellow = '\x1B[33m';
  static const _red = '\x1B[31m';

  @override
  void debug(String message, [Object? context]) =>
      _log(_gray, '[DEBUG]', message, context);

  @override
  void info(String message, [Object? context]) =>
      _log(_cyan, '[INFO] ', message, context);

  @override
  void warning(String message, [Object? context, StackTrace? st]) {
    _log(_yellow, '[WARN] ', message, context);
  }

  @override
  void error(String message, [Object? context, StackTrace? st]) {
    _log(_red, '[ERROR]', message, context);
  }

  void _log(String color, String level, String message, Object? context) {
    final ctx = context != null ? ' | $context' : '';
    print('$color$level $message$ctx$_reset');
  }
}
