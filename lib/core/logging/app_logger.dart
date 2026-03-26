// coverage:ignore-file

abstract interface class AppLogger {
  void debug(String message, [Object? context]);
  void info(String message, [Object? context]);
  void warning(String message, [Object? context, StackTrace? st]);
  void error(String message, [Object? context, StackTrace? st]);
}
