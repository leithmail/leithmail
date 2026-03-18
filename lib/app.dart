import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leithmail/app_bindings.dart';
import 'package:leithmail/app_routes.dart';
import 'package:leithmail/presentation/dashboard/dashboard_bindings.dart';
import 'package:leithmail/presentation/dashboard/dashboard_screen.dart';
import 'package:leithmail/presentation/login/login_bindings.dart';
import 'package:leithmail/presentation/login/login_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Leithmail',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      initialRoute: AppRoutes.login,
      unknownRoute: _AppPages.login,
      getPages: _AppPages.all,
    );
  }
}

abstract class _AppPages {
  static final login = GetPage(
    name: AppRoutes.login,
    page: () => const LoginScreen(),
    binding: LoginBindings(),
  );

  static final dashboard = GetPage(
    name: AppRoutes.dashboard,
    page: () => const DashboardScreen(),
    binding: DashboardBindings(),
  );

  static final all = [login, dashboard];
}
