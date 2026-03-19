import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';

class AccountSettingsController {
  AccountSettingsController(this._removeAccountUsecase);

  final RemoveAccountUsecase _removeAccountUsecase;

  final Signal<bool> isLoading = signal(false);
  final Signal<String?> errorMessage = signal(null);

  Future<bool> removeAccount(AccountId id) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _removeAccountUsecase(id);

    isLoading.value = false;

    switch (result) {
      case Success():
        return true;
      case Failure(:final failure):
        errorMessage.value = 'Failed to remove account: $failure';
        return false;
    }
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
  }
}
