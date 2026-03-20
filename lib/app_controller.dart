import 'package:leithmail/presentation/account_settings/account_settings_controller.dart';
import 'package:leithmail/presentation/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/base/controller_base.dart';
import 'package:leithmail/presentation/base/controller_factory.dart';
import 'package:leithmail/presentation/dashboard/dashboard_controller.dart';
import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';

class AppController extends ControllerBase {
  AppController({
    required this.getActiveAccountUsecase,
    required this.getAllAccountsUsecase,
    required this.setActiveAccountUsecase,
    required this.dashboardControllerFactory,
    required this.addAccountControllerFactory,
  });

  final ControllerFactory<DashboardController> dashboardControllerFactory;
  final ControllerFactory<AddAccountController> addAccountControllerFactory;

  final GetActiveAccountUsecase getActiveAccountUsecase;
  final GetAllAccountsUsecase getAllAccountsUsecase;
  final SetActiveAccountUsecase setActiveAccountUsecase;

  final Signal<bool> isLoading = signal(
    true,
    debugLabel: 'AppController.isLoading',
  );
  final Signal<bool> hasAccounts = signal(
    false,
    debugLabel: 'AppController.hasAccounts',
  );
  final Signal<Account?> activeAccount = signal(
    null,
    debugLabel: 'AppController.activeAccount',
  );

  @override
  Future<void> onInit() => reload();

  Future<void> reload() async {
    isLoading.value = true;

    final accountsResult = await getAllAccountsUsecase(NoInput);
    switch (accountsResult) {
      case Failure():
        isLoading.value = false;
        return;
      case Success(:final data) when data.isEmpty:
        hasAccounts.value = false;
        isLoading.value = false;
        return;
      case Success(data: final accounts):
        hasAccounts.value = true;
        final activeResult = await getActiveAccountUsecase(NoInput);
        if (activeResult case Success(data: final activeAcc)) {
          if (activeAcc != null) {
            activeAccount.value = activeAcc;
          } else {
            await setActiveAccountUsecase(accounts.first.id);
            activeAccount.value = accounts.first;
          }
        }
        isLoading.value = false;
    }
  }

  /// Called after a new account is successfully added,
  /// so the app re-evaluates which screen to show.
  Future<void> onAccountAdded() async => reload();

  /// Called after the active account is removed.
  Future<void> onAccountRemoved() async => reload();

  @override
  void onDispose() {
    isLoading.dispose();
    hasAccounts.dispose();
    activeAccount.dispose();
  }
}
