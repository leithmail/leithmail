import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:leithmail/presentation/logging/signals_log_ovserver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leithmail/app.dart';
import 'package:leithmail/core/logging/app_logger_console.dart';
import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/data/account_repository_impl.dart';
import 'package:leithmail/data/active_account_repository_impl.dart';
import 'package:leithmail/data/email_repository_impl_mock.dart';
import 'package:leithmail/data/mailbox_repository_impl_mock.dart';
import 'package:leithmail/data/storage_service_factory_impl.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/domain/usecases/get_emails_usecase.dart';
import 'package:leithmail/domain/usecases/get_mailboxes_usecase.dart';
import 'package:leithmail/presentation/account_settings/account_settings_controller.dart';
import 'package:leithmail/presentation/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/dashboard/dashboard_controller.dart';
import 'package:leithmail/app_controller.dart';
import 'package:signals/signals_flutter.dart';

void main() async {
  Log.setLogger(AppLoggerConsole());
  Log.info('app starting');
  SignalsObserver.instance = const SignalsLogObserver();

  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final sharedPreferences = await SharedPreferences.getInstance();
  const flutterSecureStorage = FlutterSecureStorage();
  final storageFactory = StorageServiceFactoryImpl(
    flutterSecureStorage: flutterSecureStorage,
    sharedPreferences: sharedPreferences,
  );

  // Repositories
  final accountRepository = AccountRepositoryImpl(
    persistent: storageFactory.secure('account'),
    cache: storageFactory.memory('account'),
  );
  final activeAccountRepository = ActiveAccountRepositoryImpl(
    persistent: storageFactory.local('active_account'),
  );

  // Account usecases — shared across controllers
  final getActiveAccountUsecase = GetActiveAccountUsecase(
    accountRepository,
    activeAccountRepository,
  );
  final getAllAccountsUsecase = GetAllAccountsUsecase(accountRepository);
  final setActiveAccountUsecase = SetActiveAccountUsecase(
    activeAccountRepository,
  );
  final addAccountUsecase = AddAccountUsecase(
    accountRepository,
    activeAccountRepository,
  );
  final removeAccountUsecase = RemoveAccountUsecase(
    accountRepository,
    activeAccountRepository,
  );

  final appController = AppController(
    getActiveAccountUsecase: getActiveAccountUsecase,
    getAllAccountsUsecase: getAllAccountsUsecase,
    setActiveAccountUsecase: setActiveAccountUsecase,
  );

  runApp(
    App(
      appController: appController,
      dashboardController: DashboardController(
        getMailboxesUsecase: GetMailboxesUsecase(MailboxRepositoryImplMock()),
        getEmailsUsecase: GetEmailsUsecase(EmailRepositoryImplMock()),
        getAllAccountsUsecase: getAllAccountsUsecase,
        setActiveAccountUsecase: setActiveAccountUsecase,
        onAccountSwitched: () => appController.boot(),
      ),
      addAccountController: AddAccountController(addAccountUsecase),
      accountSettingsController: AccountSettingsController(
        removeAccountUsecase,
      ),
    ),
  );
}
