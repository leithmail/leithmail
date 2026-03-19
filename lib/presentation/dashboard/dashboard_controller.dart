import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/mock_email.dart';
import 'package:leithmail/domain/entities/mock_mailbox.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/domain/usecases/get_emails_usecase.dart';
import 'package:leithmail/domain/usecases/get_mailboxes_usecase.dart';

class DashboardController {
  DashboardController({
    required this.getMailboxesUsecase,
    required this.getEmailsUsecase,
    required this.getAllAccountsUsecase,
    required this.setActiveAccountUsecase,
    required this.onAccountSwitched,
  });

  final GetMailboxesUsecase getMailboxesUsecase;
  final GetEmailsUsecase getEmailsUsecase;
  final GetAllAccountsUsecase getAllAccountsUsecase;
  final SetActiveAccountUsecase setActiveAccountUsecase;

  /// Called after switching accounts so AppController can update
  /// its activeAccount signal and any other app-level state.
  final Future<void> Function() onAccountSwitched;

  final Signal<List<MockMailbox>> mailboxes = signal([]);
  final Signal<List<MockEmail>> emails = signal([]);
  final Signal<List<Account>> accounts = signal([]);
  final Signal<MockMailbox?> selectedMailbox = signal(null);
  final Signal<MockEmail?> selectedEmail = signal(null);
  final Signal<bool> isAccountPanelOpen = signal(false);
  final Signal<bool> isLoadingMailboxes = signal(false);
  final Signal<bool> isLoadingEmails = signal(false);

  Future<void> init() async {
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
    await init();
  }

  void toggleAccountPanel() {
    isAccountPanelOpen.value = !isAccountPanelOpen.value;
  }

  void closeAccountPanel() {
    isAccountPanelOpen.value = false;
  }

  void dispose() {
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
