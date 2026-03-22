import 'dart:ui';

import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/usecases/get_emails_usecase.dart';
import 'package:leithmail/domain/usecases/get_mailboxes_usecase.dart';
import 'package:leithmail/presentation/views/account_settings/account_settings_controller_factory.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller_factory.dart';
import 'package:leithmail/presentation/base/controller_factory_base.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller.dart';
import 'package:leithmail/presentation/models/account_summary.dart';
import 'package:signals/signals_flutter.dart';

class DashboardControllerFactoryInput {
  const DashboardControllerFactoryInput({
    required this.activeAccount,
    required this.accountSummariesList,
    required this.onAccountSwitched,
  });

  final ReadonlySignal<Account?> activeAccount;
  final ReadonlySignal<List<AccountSummary>> accountSummariesList;
  final VoidCallback onAccountSwitched;
}

class DashboardControllerFactory
    extends
        ControllerFactoryBase<
          DashboardController,
          DashboardControllerFactoryInput
        > {
  final GetMailboxesUsecase getMailboxesUsecase;
  final GetEmailsUsecase getEmailsUsecase;
  final AddAccountControllerFactory addAccountControllerFactory;
  final AccountSettingsControllerFactory accountSettingsControllerFactory;

  DashboardControllerFactory({
    required this.getMailboxesUsecase,
    required this.getEmailsUsecase,
    required this.addAccountControllerFactory,
    required this.accountSettingsControllerFactory,
  });

  @override
  DashboardController create(DashboardControllerFactoryInput input) =>
      DashboardController(
        getMailboxesUsecase: getMailboxesUsecase,
        getEmailsUsecase: getEmailsUsecase,
        addAccountControllerFactory: addAccountControllerFactory,
        accountSettingsControllerFactory: accountSettingsControllerFactory,
        accountSummariesList: input.accountSummariesList,
        activeAccount: input.activeAccount,
        onAccountSwitched: input.onAccountSwitched,
      );
}
