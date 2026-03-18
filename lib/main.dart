import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:leithmail/app.dart';
import 'package:leithmail/app_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await applyAppBindings();
  runApp(const App());
}
