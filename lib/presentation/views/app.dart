import 'package:flutter/material.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/presentation/views/add_account/add_account_view.dart';
import 'package:leithmail/presentation/views/app_controller.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_view.dart';
import 'package:leithmail/presentation/theme/app_theme.dart';

class App
    extends
        ControllerWidget<
          AppController,
          AppControllerBindings,
          AppControllerInputs
        > {
  const App({super.key, required super.factory, required super.inputs});

  @override
  Widget build(BuildContext context, AppController controller) {
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

        if (!hasAccounts || controller.lastActiveAccount == null) {
          return AddAccountView(
            factory: controller.bindings.addAccountControllerFactory,
            inputs: (
              onAccountAdded: controller.onAccountSwitched,
              canGoBack: false,
            ),
          );
        }

        return DashboardView(
          key: Key(controller.lastActiveAccount!.value.id.value),
          factory: controller.bindings.dashboardControllerFactory,
          inputs: (
            activeAccount: controller.lastActiveAccount!,
            accountSummariesList: controller.accountSummariesList,
            onAccountSwitched: controller.onAccountSwitched,
          ),
        );
      }, debugLabel: 'App.root'),
    );
  }
}
