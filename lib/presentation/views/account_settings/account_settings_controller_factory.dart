import 'dart:ui';

import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/presentation/views/account_settings/account_settings_controller.dart';
import 'package:leithmail/presentation/base/controller_factory_base.dart';

class AccountSettingsControllerFactoryInput {
  final Account account;
  final VoidCallback onAccountRemoved;

  AccountSettingsControllerFactoryInput({
    required this.account,
    required this.onAccountRemoved,
  });
}

class AccountSettingsControllerFactory
    extends
        ControllerFactoryBase<
          AccountSettingsController,
          AccountSettingsControllerFactoryInput
        > {
  AccountSettingsControllerFactory({required this.removeAccountUsecase});

  final RemoveAccountUsecase removeAccountUsecase;

  @override
  AccountSettingsController create(
    AccountSettingsControllerFactoryInput input,
  ) {
    return AccountSettingsController(
      removeAccountUsecase: removeAccountUsecase,
      onAccountRemoved: input.onAccountRemoved,
      account: input.account,
    );
  }
}
