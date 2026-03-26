import 'package:flutter/material.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/presentation/views/add_account/add_account_view.dart';
import 'package:leithmail/presentation/views/app_controller.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_view.dart';
import 'package:leithmail/presentation/theme/app_theme.dart';
import 'package:web/web.dart' as web;

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
        final hasAccounts = controller.hasAccounts.value;
        final isAuthCallbackProcessing =
            controller.isAuthCallbackProcessing.value;

        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (isAuthCallbackProcessing) {
          return AddAccountView(
            factory: controller.bindings.addAccountControllerFactory,
            inputs: AddAccountControllerInputs(
              onAccountAdded: () {
                controller.isLoading.value = true;
                controller.isAuthCallbackProcessing.value = false;
                // redirect to the app root to clear any auth callback query parameters from the URL
                web.window.location.href = Uri.base.origin;
              },
              canGoBack: true,
              onBack: () {
                controller.isLoading.value = true;
                controller.isAuthCallbackProcessing.value = false;
                // redirect to the app root to clear any auth callback query parameters from the URL
                web.window.location.href = Uri.base.origin;
              },
              authCode: controller.inputs.authCode,
              authState: controller.inputs.authState,
            ),
          );
        }

        if (!hasAccounts || controller.lastActiveAccount == null) {
          return AddAccountView(
            factory: controller.bindings.addAccountControllerFactory,
            inputs: AddAccountControllerInputs(
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
