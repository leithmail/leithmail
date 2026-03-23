import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/presentation/views/account_settings/account_settings_controller.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/base/controller_base.dart';
import 'package:leithmail/presentation/models/account_summary.dart';
import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/mock_email.dart';
import 'package:leithmail/domain/entities/mock_mailbox.dart';
import 'package:leithmail/domain/usecases/get_emails_usecase.dart';
import 'package:leithmail/domain/usecases/get_mailboxes_usecase.dart';

typedef DashboardControllerBindings = ({
  GetMailboxesUsecase getMailboxesUsecase,
  GetEmailsUsecase getEmailsUsecase,
  SetActiveAccountUsecase setActiveAccountUsecase,
  AddAccountControllerFactory addAccountControllerFactory,
  AccountSettingsControllerFactory accountSettingsControllerFactory,
});

typedef DashboardControllerInputs = ({
  ReadonlySignal<Account> activeAccount,
  ReadonlySignal<List<AccountSummary>> accountSummariesList,
  void Function() onAccountSwitched,
});

class DashboardControllerFactory
    extends
        ControllerFactoryBase<
          DashboardController,
          DashboardControllerBindings,
          DashboardControllerInputs
        > {
  DashboardControllerFactory({required super.bindings});

  @override
  create(inputs) => DashboardController(bindings: bindings, inputs: inputs);
}

class DashboardController
    extends
        ControllerBase<DashboardControllerBindings, DashboardControllerInputs> {
  DashboardController({required super.bindings, required super.inputs});

  final Signal<List<MockMailbox>> mailboxes = signal(
    [],
    debugLabel: 'DashboardController.mailboxes',
  );
  final Signal<List<MockEmail>> emails = signal(
    [],
    debugLabel: 'DashboardController.emails',
  );
  final Signal<MockMailbox?> selectedMailbox = signal(
    null,
    debugLabel: 'DashboardController.selectedMailbox',
  );
  final Signal<MockEmail?> selectedEmail = signal(
    null,
    debugLabel: 'DashboardController.selectedEmail',
  );
  final Signal<bool> isAccountSelectorPaneOpen = signal(
    false,
    debugLabel: 'DashboardController.isAccountSelectorPaneOpen',
  );
  final Signal<bool> isLoadingMailboxes = signal(
    false,
    debugLabel: 'DashboardController.isLoadingMailboxes',
  );
  final Signal<bool> isLoadingEmails = signal(
    false,
    debugLabel: 'DashboardController.isLoadingEmails',
  );

  @override
  Future<void> onInit() => reload();

  Future<void> reload() async {
    await _loadMailboxes();
  }

  Future<void> _loadMailboxes() async {
    isLoadingMailboxes.value = true;
    final result = await bindings.getMailboxesUsecase(NoInput);
    if (result case Success(:final data)) {
      mailboxes.value = data;
      if (data.isNotEmpty) await selectMailbox(data.first);
    }
    isLoadingMailboxes.value = false;
  }

  Future<void> selectMailbox(MockMailbox mailbox) async {
    isLoadingEmails.value = true;
    selectedMailbox.value = mailbox;
    selectedEmail.value = null;
    final result = await bindings.getEmailsUsecase(mailbox.id);
    if (result case Success(:final data)) {
      emails.value = data;
    }
    isLoadingEmails.value = false;
  }

  Future<void> setActiveAccount(AccountId id) async {
    await bindings.setActiveAccountUsecase(id);
  }

  void selectEmail(MockEmail email) {
    selectedEmail.value = email;
  }

  void clearSelectedEmail() {
    selectedEmail.value = null;
  }

  void toggleAccountSelectorPane() {
    isAccountSelectorPaneOpen.value = !isAccountSelectorPaneOpen.value;
  }

  void closeAccountSelectorPane() {
    isAccountSelectorPaneOpen.value = false;
  }

  @override
  void onDispose() {
    mailboxes.dispose();
    emails.dispose();
    selectedMailbox.dispose();
    selectedEmail.dispose();
    isAccountSelectorPaneOpen.dispose();
    isLoadingMailboxes.dispose();
    isLoadingEmails.dispose();
  }
}
