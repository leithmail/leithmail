import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/presentation/account_settings/account_settings_controller.dart';
import 'package:leithmail/presentation/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/add_account/add_account_screen.dart';
import 'package:leithmail/app_controller.dart';
import 'package:leithmail/presentation/dashboard/dashboard_controller.dart';
import 'package:leithmail/presentation/dashboard/dashboard_screen.dart';
import 'package:leithmail/presentation/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    required this.appController,
    required this.dashboardController,
    required this.addAccountController,
    required this.accountSettingsController,
  });

  final AppController appController;
  final DashboardController dashboardController;
  final AddAccountController addAccountController;
  final AccountSettingsController accountSettingsController;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    widget.appController.boot();
  }

  @override
  void dispose() {
    widget.appController.dispose();
    widget.dashboardController.dispose();
    widget.addAccountController.dispose();
    widget.accountSettingsController.dispose();
    super.dispose();
  }

  Future<void> _onAccountAdded() async {
    widget.dashboardController.closeAccountPanel();
    await widget.appController.onAccountAdded();
    await widget.dashboardController.init();
  }

  Future<void> _onAccountRemoved() async {
    await widget.appController.onAccountRemoved();
    await widget.dashboardController.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leithmail',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Watch((context) {
        final isLoading = widget.appController.isLoading.value;
        final hasAccounts = widget.appController.hasAccounts.value;

        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!hasAccounts) {
          return AddAccountScreen(
            controller: widget.addAccountController,
            canGoBack: false,
            onSuccess: _onAccountAdded,
          );
        }

        return DashboardScreen(
          controller: widget.dashboardController,
          addAccountController: widget.addAccountController,
          accountSettingsController: widget.accountSettingsController,
          activeAccount: widget.appController.activeAccount,
          onAccountAdded: _onAccountAdded,
          onAccountRemoved: _onAccountRemoved,
        );
      }),
    );
  }
}
