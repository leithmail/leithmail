import 'package:leithmail/presentation/views/account_settings/account_settings_controller_factory.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller_factory.dart';
import 'package:leithmail/presentation/base/controller_base.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller_factory.dart';
import 'package:leithmail/presentation/models/account_summary.dart';
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
    required this.accountSettingsControllerFactory,
  });

  final DashboardControllerFactory dashboardControllerFactory;
  final AddAccountControllerFactory addAccountControllerFactory;
  final AccountSettingsControllerFactory accountSettingsControllerFactory;

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

  final Signal<List<Account>> accountsList = signal(
    [],
    debugLabel: 'AppController.accountsList',
  );
  late final Computed<List<AccountSummary>> accountSummariesList = computed(
    () => accountsList.value
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
        final activeResult = await getActiveAccountUsecase(NoInput);
        if (activeResult case Success(data: final activeAcc)) {
          if (activeAcc != null) {
            activeAccount.value = activeAcc;
          } else {
            await setActiveAccountUsecase(accounts.first.id);
            activeAccount.value = accounts.first;
          }
        }
        accountsList.value = accounts;
        hasAccounts.value = true;
        isLoading.value = false;
    }
  }

  /// Called after new active actound is selected.
  void onAccountSwitched() {
    reload();
  }

  @override
  void onDispose() {
    isLoading.dispose();
    hasAccounts.dispose();
    activeAccount.dispose();
    accountSummariesList.dispose();
    accountsList.dispose();
  }
}
