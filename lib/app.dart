import 'package:flutter/material.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller_factory.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller_factory.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/presentation/views/add_account/add_account_view.dart';
import 'package:leithmail/app_controller.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_view.dart';
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
          return AddAccountView(
            controller: controller.addAccountControllerFactory(
              AddAccountControllerFactoryInput(
                onAccountAdded: controller.onAccountSwitched,
                canGoBack: false,
              ),
            ),
          );
        }

        return DashboardView(
          controller: controller.dashboardControllerFactory(
            DashboardControllerFactoryInput(
              activeAccount: controller.activeAccount,
              accountSummariesList: controller.accountSummariesList,
              onAccountSwitched: controller.onAccountSwitched,
            ),
          ),
        );
      }, debugLabel: 'App.root'),
    );
  }
}
