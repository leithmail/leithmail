import 'package:leithmail/presentation/account_settings/account_settings_controller.dart';
import 'package:leithmail/presentation/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/base/controller_base.dart';
import 'package:leithmail/presentation/base/controller_factory.dart';
import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/mock_email.dart';
import 'package:leithmail/domain/entities/mock_mailbox.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/domain/usecases/get_emails_usecase.dart';
import 'package:leithmail/domain/usecases/get_mailboxes_usecase.dart';

class DashboardController extends ControllerBase {
  DashboardController({
    required this.getMailboxesUsecase,
    required this.getEmailsUsecase,
    required this.getAllAccountsUsecase,
    required this.setActiveAccountUsecase,
    required this.onAccountSwitched,
    required this.addAccountControllerFactory,
    required this.accountSettingsControllerFactory,
  });

  final GetMailboxesUsecase getMailboxesUsecase;
  final GetEmailsUsecase getEmailsUsecase;
  final GetAllAccountsUsecase getAllAccountsUsecase;
  final SetActiveAccountUsecase setActiveAccountUsecase;

  final ControllerFactory<AddAccountController> addAccountControllerFactory;
  final ControllerFactory<AccountSettingsController>
  accountSettingsControllerFactory;

  /// Called after switching accounts so AppController can update
  /// its activeAccount signal and any other app-level state.
  final Future<void> Function() onAccountSwitched;

  final Signal<List<MockMailbox>> mailboxes = signal(
    [],
    debugLabel: 'DashboardController.mailboxes',
  );
  final Signal<List<MockEmail>> emails = signal(
    [],
    debugLabel: 'DashboardController.emails',
  );
  final Signal<List<Account>> accounts = signal(
    [],
    debugLabel: 'DashboardController.accounts',
  );
  final Signal<MockMailbox?> selectedMailbox = signal(
    null,
    debugLabel: 'DashboardController.selectedMailbox',
  );
  final Signal<MockEmail?> selectedEmail = signal(
    null,
    debugLabel: 'DashboardController.selectedEmail',
  );
  final Signal<bool> isAccountPanelOpen = signal(
    false,
    debugLabel: 'DashboardController.isAccountPanelOpen',
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
    await Future.wait([_loadMailboxes(), _loadAccounts()]);
  }

  Future<void> _loadMailboxes() async {
    isLoadingMailboxes.value = true;
    final result = await getMailboxesUsecase(NoInput);
    if (result case Success(:final data)) {
      mailboxes.value = data;
      if (data.isNotEmpty) await selectMailbox(data.first);
    }
    isLoadingMailboxes.value = false;
  }

  Future<void> _loadAccounts() async {
    final result = await getAllAccountsUsecase(NoInput);
    if (result case Success(:final data)) {
      accounts.value = data;
    }
  }

  Future<void> selectMailbox(MockMailbox mailbox) async {
    selectedMailbox.value = mailbox;
    selectedEmail.value = null;
    isLoadingEmails.value = true;
    final result = await getEmailsUsecase(mailbox.id);
    if (result case Success(:final data)) {
      emails.value = data;
    }
    isLoadingEmails.value = false;
  }

  void selectEmail(MockEmail email) {
    selectedEmail.value = email;
  }

  void clearSelectedEmail() {
    selectedEmail.value = null;
  }

  Future<void> switchAccount(AccountId id) async {
    await setActiveAccountUsecase(id);
    closeAccountPanel();
    await onAccountSwitched();
    await reload();
  }

  void toggleAccountPanel() {
    isAccountPanelOpen.value = !isAccountPanelOpen.value;
  }

  void closeAccountPanel() {
    isAccountPanelOpen.value = false;
  }

  @override
  void onDispose() {
    mailboxes.dispose();
    emails.dispose();
    accounts.dispose();
    selectedMailbox.dispose();
    selectedEmail.dispose();
    isAccountPanelOpen.dispose();
    isLoadingMailboxes.dispose();
    isLoadingEmails.dispose();
  }
}
