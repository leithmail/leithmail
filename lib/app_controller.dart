import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';

class AppController {
  AppController({
    required this.getActiveAccountUsecase,
    required this.getAllAccountsUsecase,
    required this.setActiveAccountUsecase,
  });

  final GetActiveAccountUsecase getActiveAccountUsecase;
  final GetAllAccountsUsecase getAllAccountsUsecase;
  final SetActiveAccountUsecase setActiveAccountUsecase;

  final Signal<bool> isLoading = signal(true);
  final Signal<bool> hasAccounts = signal(false);
  final Signal<Account?> activeAccount = signal(null);

  Future<void> boot() async {
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
  Future<void> onAccountAdded() async => boot();

  /// Called after the active account is removed.
  Future<void> onAccountRemoved() async => boot();

  void dispose() {
    isLoading.dispose();
    hasAccounts.dispose();
    activeAccount.dispose();
  }
}
