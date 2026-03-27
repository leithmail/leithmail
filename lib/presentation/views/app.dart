import 'package:flutter/material.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller.dart';
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
      theme: AppTheme.light(Theme.of(context).textTheme),
      darkTheme: AppTheme.dark(Theme.of(context).textTheme),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Watch((context) {
        final isLoading = controller.isLoading.value;
        final isAuthCallbackProcessing =
            controller.isAuthCallbackProcessing.value;
        final isAuthenticated = controller.isAuthenticated.value;

        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (isAuthCallbackProcessing) {
          return AddAccountView(
            factory: controller.bindings.addAccountControllerFactory,
            inputs: AddAccountControllerInputs(
              onSuccess: () {
                controller.isLoading.value = true;
                controller.isAuthCallbackProcessing.value = false;
                controller.onAccountSwitched();
              },
              onCancel: () {
                controller.isLoading.value = true;
                controller.isAuthCallbackProcessing.value = false;
                controller.onAccountSwitched();
              },
              oidcCallbackData: controller.inputs.oidcCallbackData,
            ),
          );
        }

        if (!isAuthenticated) {
          return AddAccountView(
            factory: controller.bindings.addAccountControllerFactory,
            inputs: AddAccountControllerInputs(
              onSuccess: controller.onAccountSwitched,
            ),
          );
        }

        return DashboardView(
          key: Key(
            controller.activeAccount.value.id.value,
          ), // force rebuild when active account changes
          factory: controller.bindings.dashboardControllerFactory,
          inputs: (
            activeAccount: controller.activeAccount,
            accountSummariesList: controller.accountSummariesList,
            onAccountSwitched: controller.onAccountSwitched,
          ),
        );
      }, debugLabel: 'App.root'),
    );
  }
}
