import 'package:flutter/widgets.dart';
import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/presentation/base/controller_base.dart';
import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';

class AddAccountController extends ControllerBase {
  AddAccountController(this._addAccountUsecase);

  final AddAccountUsecase _addAccountUsecase;

  final Signal<bool> isLoading = signal(
    false,
    debugLabel: 'AddAccountController.isLoading',
  );
  final Signal<String?> errorMessage = signal(
    null,
    debugLabel: 'AddAccountController.errorMessage',
  );

  final emailInputController = TextEditingController();

  Future<bool> addAccount(String email) async {
    if (email.trim().isEmpty) {
      errorMessage.value = 'Please enter an email address.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final Account account;
    try {
      account = Account.mock(email: email.trim());
    } catch (e) {
      Log.warning('[AddAccountController] invalid email address', e);
      errorMessage.value = 'Invalid email address.';
      isLoading.value = false;
      return false;
    }
    final result = await _addAccountUsecase(account);

    isLoading.value = false;

    switch (result) {
      case Success():
        return true;
      case Failure(:final failure):
        errorMessage.value = 'Failed to add account: $failure';
        return false;
    }
  }

  @override
  void onDispose() {
    emailInputController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
