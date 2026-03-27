import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/domain/usecases/oidc_usecases.dart';
import 'package:leithmail/presentation/views/account_settings/account_settings_controller.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/base/controller_base.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller.dart';
import 'package:leithmail/presentation/models/account_summary.dart';
import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';

typedef AppControllerBindings = ({
  DashboardControllerFactory dashboardControllerFactory,

  AddAccountControllerFactory addAccountControllerFactory,
  AccountSettingsControllerFactory accountSettingsControllerFactory,

  GetAllAccountsUsecase getAllAccountsUsecase,
  GetActiveAccountIdUsecase getActiveAccountIdUsecase,
  RefreshAndGetAccountUsecase refreshAndGetAccountUsecase,
});

typedef AppControllerInputs = ({
  FinishAuthFlowOidcUsecaseInput? oidcCallbackData,
});

class AppControllerFactory
    extends
        ControllerFactoryBase<
          AppController,
          AppControllerBindings,
          AppControllerInputs
        > {
  AppControllerFactory({required super.bindings});

  @override
  AppController create(AppControllerInputs inputs) =>
      AppController(bindings: bindings, inputs: inputs);
}

class AppController
    extends ControllerBase<AppControllerBindings, AppControllerInputs> {
  AppController({required super.bindings, required super.inputs});

  final Signal<bool> isLoading = signal(
    true,
    debugLabel: 'AppController.isLoading',
  );

  final Signal<bool> isAuthCallbackProcessing = signal(
    false,
    debugLabel: 'AppController.isAuthCallbackProcessing',
  );

  Signal<Account> activeAccount = signal(
    Account.mock(),
    debugLabel: 'AppController.activeAccount',
  );

  final Signal<bool> isAuthenticated = signal(
    false,
    debugLabel: 'AppController.isAuthenticated',
  );

  final Signal<List<Account>> _accountsList = signal(
    [],
    debugLabel: 'AppController.accountsList',
  );

  late final Computed<List<AccountSummary>> accountSummariesList = computed(
    () => _accountsList.value
        .map((a) => AccountSummary(id: a.id, unreadCount: 0))
        .toList(),
    debugLabel: 'AppController.accountSummariesList',
  );

  @override
  Future<void> onInit() async {
    if (inputs.oidcCallbackData != null) {
      isAuthCallbackProcessing.value = true;
      isLoading.value = false;
    }
    reloadAccounts();
  }

  Future<void> updateActiveAccount() async {
    final AccountId activeAccountId;
    final activeAccountIdResult = await bindings.getActiveAccountIdUsecase(
      NoInput,
    );

    switch (activeAccountIdResult) {
      case Failure():
        activeAccount.value = Account.mock();
        isAuthenticated.value = false;
        return;
      case Success(data: final accountId):
        if (accountId == null) {
          activeAccount.value = Account.mock();
          isAuthenticated.value = false;
          return;
        }
        activeAccountId = accountId;
    }

    final activeAccountResult = await bindings.refreshAndGetAccountUsecase(
      activeAccountId,
    );
    switch (activeAccountResult) {
      case Success(data: final account):
        if (account != null) {
          activeAccount.value = account;
          isAuthenticated.value = true;
        } else {
          isAuthenticated.value = false;
          activeAccount.value = Account.mock();
        }
        return;
      case Failure():
        // Account exists but the authentication expired and couldn't be refreshed, or JMAP session couldn't be refreshed
        // TODO: implement some login_hint or error message to explain the situation to the user
        isAuthenticated.value = false;
        activeAccount.value = Account.mock();
        return;
    }
  }

  Future<void> reloadAccounts() async {
    Log.info('[$runtimeType] reloadAccounts');
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 1));

    final accountsResult = await bindings.getAllAccountsUsecase(NoInput);
    switch (accountsResult) {
      case Failure():
        isLoading.value = false;
        return;
      case Success(data: final accounts):
        _accountsList.value = accounts;
        await updateActiveAccount();
        isLoading.value = false;
    }
  }

  void onAccountSwitched() {
    reloadAccounts();
  }

  @override
  void onDispose() {
    isLoading.dispose();
    accountSummariesList.dispose();
    _accountsList.dispose();
    activeAccount.dispose();
    isAuthenticated.dispose();
    isAuthCallbackProcessing.dispose();
  }
}
