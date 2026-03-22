import 'dart:ui';

import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/base/controller_factory_base.dart';

class AddAccountControllerFactoryInput {
  final VoidCallback onAccountAdded;
  final bool canGoBack;

  AddAccountControllerFactoryInput({
    required this.onAccountAdded,
    required this.canGoBack,
  });
}

class AddAccountControllerFactory
    extends
        ControllerFactoryBase<
          AddAccountController,
          AddAccountControllerFactoryInput
        > {
  final AddAccountUsecase addAccountUsecase;

  AddAccountControllerFactory({required this.addAccountUsecase});

  @override
  AddAccountController create(AddAccountControllerFactoryInput input) {
    return AddAccountController(
      addAccountUsecase: addAccountUsecase,
      onAccountAdded: input.onAccountAdded,
      canGoBack: input.canGoBack,
    );
  }
}
