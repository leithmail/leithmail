import 'package:leithmail/core/logging/log.dart';
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

  GetActiveAccountUsecase getActiveAccountUsecase,
  GetAllAccountsUsecase getAllAccountsUsecase,
  SetActiveAccountUsecase setActiveAccountUsecase,
});

typedef AppControllerInputs = void;

class AppControllerFactory
    extends
        ControllerFactoryBase<
          AppController,
          AppControllerBindings,
          AppControllerInputs
        > {
  AppControllerFactory({required super.bindings});

  @override
  AppController create(void inputs) =>
      AppController(bindings: bindings, inputs: inputs);
}

class AppController
    extends ControllerBase<AppControllerBindings, AppControllerInputs> {
  AppController({required super.bindings, required super.inputs});

  final Signal<bool> isLoading = signal(
    true,
    debugLabel: 'AppController.isLoading',
  );

  Signal<Account>? lastActiveAccount;

  final Signal<List<Account>> _accountsList = signal(
    [],
    debugLabel: 'AppController.accountsList',
  );

  late final Computed<bool> hasAccounts = computed(
    () => _accountsList.value.isNotEmpty,
    debugLabel: 'AppController.hasAccounts',
  );

  late final Computed<List<AccountSummary>> accountSummariesList = computed(
    () => _accountsList.value
        .map(
          (a) => AccountSummary(
            id: a.id,
            emailAddress: a.emailAddress,
            unreadCount: 0,
          ),
        )
        .toList(),
    debugLabel: 'AppController.accountSummariesList',
  );

  @override
  Future<void> onInit() => reloadAccounts();

  void _initAndSetLastActiveAccountSignal(Account account) {
    if (lastActiveAccount != null) {
      lastActiveAccount!.value = account;
    } else {
      lastActiveAccount = Signal(
        account,
        debugLabel: 'AppController.lastActiveAccount',
      );
    }
  }

  Future<void> updateLastActiveAccountSignal() async {
    final activeAccountResult = await bindings.getActiveAccountUsecase(NoInput);
    switch (activeAccountResult) {
      case Success(data: final activeAccount):
        if (activeAccount != null) {
          _initAndSetLastActiveAccountSignal(activeAccount);
        }
        if (activeAccount == null && hasAccounts.value) {
          _initAndSetLastActiveAccountSignal(_accountsList.value.first);
          return;
        }
        return;
      case Failure():
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Future<void> reloadAccounts() async {
    Log.info('AppController.reloadAccounts');
    isLoading.value = true;

    final accountsResult = await bindings.getAllAccountsUsecase(NoInput);
    switch (accountsResult) {
      case Failure():
        isLoading.value = false;
        return;
      case Success(:final data) when data.isEmpty:
        isLoading.value = false;
        return;
      case Success(data: final accounts):
        _accountsList.value = accounts;
        updateLastActiveAccountSignal();
        isLoading.value = false;
    }
  }

  void onAccountSwitched() {
    reloadAccounts();
  }

  @override
  void onDispose() {
    isLoading.dispose();
    hasAccounts.dispose();
    accountSummariesList.dispose();
    _accountsList.dispose();
    lastActiveAccount?.dispose();
  }
}
