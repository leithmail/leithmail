import 'dart:ui';

import 'package:leithmail/presentation/views/account_settings/account_settings_controller_factory.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller_factory.dart';
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

class DashboardController extends ControllerBase {
  DashboardController({
    required this.getMailboxesUsecase,
    required this.getEmailsUsecase,
    required this.onAccountSwitched,
    required this.addAccountControllerFactory,
    required this.accountSettingsControllerFactory,
    required this.accountSummariesList,
    required this.activeAccount,
  });

  final GetMailboxesUsecase getMailboxesUsecase;
  final GetEmailsUsecase getEmailsUsecase;

  final AddAccountControllerFactory addAccountControllerFactory;
  final AccountSettingsControllerFactory accountSettingsControllerFactory;

  final ReadonlySignal<List<AccountSummary>> accountSummariesList;
  final ReadonlySignal<Account?> activeAccount;

  final VoidCallback onAccountSwitched;

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
  final Signal<bool> isAccountSelectorViewOpen = signal(
    false,
    debugLabel: 'DashboardController.isAccountSelectorViewOpen',
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
    final result = await getMailboxesUsecase(NoInput);
    if (result case Success(:final data)) {
      mailboxes.value = data;
      if (data.isNotEmpty) await selectMailbox(data.first);
    }
    isLoadingMailboxes.value = false;
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

  void toggleAccountSelectorView() {
    isAccountSelectorViewOpen.value = !isAccountSelectorViewOpen.value;
  }

  void closeAccountSelectorView() {
    isAccountSelectorViewOpen.value = false;
  }

  @override
  void onDispose() {
    mailboxes.dispose();
    emails.dispose();
    accounts.dispose();
    selectedMailbox.dispose();
    selectedEmail.dispose();
    isAccountSelectorViewOpen.dispose();
    isLoadingMailboxes.dispose();
    isLoadingEmails.dispose();
    accountSummariesList.dispose();
    activeAccount.dispose();
  }
}
