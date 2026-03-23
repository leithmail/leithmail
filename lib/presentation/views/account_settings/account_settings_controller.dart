import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/presentation/base/controller_base.dart';
import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';

typedef AccountSettingsControllerInputs = ({
  Account account,
  void Function() onAccountRemoved,
});

typedef AccountSettingsControllerBindings = ({
  RemoveAccountUsecase removeAccountUsecase,
});

class AccountSettingsControllerFactory
    extends
        ControllerFactoryBase<
          AccountSettingsController,
          AccountSettingsControllerBindings,
          AccountSettingsControllerInputs
        > {
  AccountSettingsControllerFactory({required super.bindings});

  @override
  AccountSettingsController create(AccountSettingsControllerInputs inputs) =>
      AccountSettingsController(bindings: bindings, inputs: inputs);
}

class AccountSettingsController
    extends
        ControllerBase<
          AccountSettingsControllerBindings,
          AccountSettingsControllerInputs
        > {
  AccountSettingsController({required super.bindings, required super.inputs});

  final Signal<bool> isLoading = signal(
    false,
    debugLabel: 'AccountSettingsController.isLoading',
  );
  final Signal<String?> errorMessage = signal(
    null,
    debugLabel: 'AccountSettingsController.errorMessage',
  );

  Future<void> removeAccount() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await bindings.removeAccountUsecase(inputs.account.id);

    isLoading.value = false;

    switch (result) {
      case Success():
        inputs.onAccountRemoved();
        return;
      case Failure(:final failure):
        errorMessage.value = 'Failed to remove account: $failure';
        return;
    }
  }

  @override
  void onDispose() {
    isLoading.dispose();
    errorMessage.dispose();
  }
}
