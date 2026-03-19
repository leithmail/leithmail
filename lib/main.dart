import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:leithmail/app.dart';
import 'package:leithmail/core/logging/app_logger_console.dart';
import 'package:leithmail/core/logging/log.dart';

void main() async {
  Log.setLogger(AppLoggerConsole());
  Log.info("app starting");

  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const App());
}
