import 'package:flutter/material.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/presentation/add_account/add_account_screen.dart';
import 'package:leithmail/app_controller.dart';
import 'package:leithmail/presentation/dashboard/dashboard_screen.dart';
import 'package:leithmail/presentation/theme/app_theme.dart';

class App extends ControllerWidget<AppController> {
  const App({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leithmail',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Watch((context) {
        final isLoading = controller.isLoading.value;
        final hasAccounts = controller.hasAccounts.value;

        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!hasAccounts) {
          return AddAccountScreen(
            controller: controller.addAccountControllerFactory.create(),
            canGoBack: false,
            onSuccess: controller.reload,
          );
        }

        return DashboardScreen(
          controller: controller.dashboardControllerFactory.create(),
          activeAccount: controller.activeAccount,
          onAccountAdded: controller.reload,
          onAccountRemoved: controller.reload,
        );
      }),
    );
  }
}
