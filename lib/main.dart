import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:http/http.dart' as http;
import 'package:leithmail/data/jmap_repository_impl.dart';
import 'package:leithmail/data/oidc_repository_impl.dart';
import 'package:leithmail/domain/usecases/fetch_jmap_session_usecase.dart';
import 'package:leithmail/domain/usecases/oidc_usecases.dart';
import 'package:leithmail/presentation/views/account_settings/account_settings_controller.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/views/app_controller.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller.dart';
import 'package:leithmail/presentation/logging/signals_log_ovserver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leithmail/presentation/views/app.dart';
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
  final httpClient = http.Client();
  final accountRepository = AccountRepositoryImpl(
    persistent: storageFactory.secure('account'),
    cache: storageFactory.memory('account'),
  );
  final activeAccountRepository = ActiveAccountRepositoryImpl(
    persistent: storageFactory.local('active_account'),
  );
  final emailRepository = EmailRepositoryImplMock();
  final mailboxesRepository = MailboxRepositoryImplMock();
  final oidcRepository = OidcRepositoryImpl(
    httpClient: httpClient,
    redirectUri: '${Uri.base.origin}/auth.html',
    customUriScheme: '',
    defaultClientId: 'leithmail',
  );

  final jmapRepository = JmapRepositoryImpl(httpClient);

  // Usecases
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

  final getMailboxesUsecase = GetMailboxesUsecase(mailboxesRepository);
  final getEmailsUsecase = GetEmailsUsecase(emailRepository);

  final discoverOidcProviderUsecase = DiscoverOidcProviderUsecase(
    oidcRepository,
  );
  final authenticateOidcUsecase = AuthenticateOidcUsecase(oidcRepository);

  final fetchJmapSessionUsecase = FetchJmapSessionUsecase(jmapRepository);

  // Controller factories
  final addAccountControllerFactory = AddAccountControllerFactory(
    bindings: (
      addAccountUsecase: addAccountUsecase,
      discoverOidcProviderUsecase: discoverOidcProviderUsecase,
      authenticateOidcUsecase: authenticateOidcUsecase,
      fetchJmapSessionUsecase: fetchJmapSessionUsecase,
    ),
  );

  final accountSettingsControllerFactory = AccountSettingsControllerFactory(
    bindings: (removeAccountUsecase: removeAccountUsecase),
  );

  final dashboardControllerFactory = DashboardControllerFactory(
    bindings: (
      getMailboxesUsecase: getMailboxesUsecase,
      getEmailsUsecase: getEmailsUsecase,
      addAccountControllerFactory: addAccountControllerFactory,
      accountSettingsControllerFactory: accountSettingsControllerFactory,
      setActiveAccountUsecase: setActiveAccountUsecase,
    ),
  );

  final appControllerFactory = AppControllerFactory(
    bindings: (
      dashboardControllerFactory: dashboardControllerFactory,
      addAccountControllerFactory: addAccountControllerFactory,
      accountSettingsControllerFactory: accountSettingsControllerFactory,
      getActiveAccountUsecase: getActiveAccountUsecase,
      getAllAccountsUsecase: getAllAccountsUsecase,
      setActiveAccountUsecase: setActiveAccountUsecase,
    ),
  );

  runApp(App(factory: appControllerFactory, inputs: null));
}
