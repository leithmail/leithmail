import 'dart:ui';

import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/presentation/base/controller_base.dart';
import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';

class AccountSettingsController extends ControllerBase {
  AccountSettingsController({
    required this.removeAccountUsecase,
    required this.onAccountRemoved,
    required this.account,
  });

  final RemoveAccountUsecase removeAccountUsecase;
  final VoidCallback onAccountRemoved;
  final Account account;

  final Signal<bool> isLoading = signal(
    false,
    debugLabel: 'AccountSettingsController.isLoading',
  );
  final Signal<String?> errorMessage = signal(
    null,
    debugLabel: 'AccountSettingsController.errorMessage',
  );

  Future<bool> removeAccount() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await removeAccountUsecase(account.id);

    isLoading.value = false;

    switch (result) {
      case Success():
        onAccountRemoved();
        return true;
      case Failure(:final failure):
        errorMessage.value = 'Failed to remove account: $failure';
        return false;
    }
  }

  @override
  void onDispose() {
    isLoading.dispose();
    errorMessage.dispose();
  }
}
