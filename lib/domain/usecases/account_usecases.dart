import 'package:fpdart/fpdart.dart';
import 'package:leithmail/core/usecase/app_failure.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/jmap_session.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';
import 'package:leithmail/domain/repositories/jmap_repository.dart';

class GetAllAccountsUsecase extends UsecaseBase<NoInput, List<Account>> {
  GetAllAccountsUsecase({required AccountRepository accountRepository})
    : _accountRepository = accountRepository;

  final AccountRepository _accountRepository;

  @override
  Future<Either<AppFailure, List<Account>>> execute(NoInput _) async {
    try {
      final accounts = await _accountRepository.getAll();
      return right(accounts);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}

class GetActiveAccountIdUsecase extends UsecaseBase<NoInput, AccountId?> {
  GetActiveAccountIdUsecase({
    required ActiveAccountRepository activeAccountRepository,
  }) : _activeAccountRepository = activeAccountRepository;

  final ActiveAccountRepository _activeAccountRepository;

  @override
  Future<Either<AppFailure, AccountId?>> execute(NoInput _) async {
    try {
      final accountId = await _activeAccountRepository.getActiveAccountId();
      return right(accountId);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}

class RefreshAndGetAccountUsecase extends UsecaseBase<AccountId, Account?> {
  final AccountRepository _accountRepository;
  final JmapRepository _jmapRepository;
  RefreshAndGetAccountUsecase({
    required AccountRepository accountRepository,
    required JmapRepository jmapRepository,
  }) : _jmapRepository = jmapRepository,
       _accountRepository = accountRepository;

  @override
  Future<Either<AppFailure, Account?>> execute(AccountId id) async {
    final Account? account;
    try {
      account = await _accountRepository.getById(id);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
    if (account == null) {
      return right(null);
    }

    final Credentials newCredentials;
    if (account.credentials.isExpired && account.credentials.canBeRefreshed) {
      // TODO: implement credentials refreshing
      return left(
        AuthFailure(
          'Credentials for account ${account.id.value} are expired and refreshing is not implemented yet',
        ),
      );
    } else if (account.credentials.isExpired) {
      return left(
        AuthFailure('Credentials for account ${account.id.value} are expired.'),
      );
    } else {
      newCredentials = account.credentials;
    }

    final JmapSession newJmapSession;
    try {
      newJmapSession = await _jmapRepository.fetchSession(
        jmapSessionEndpoint: account.jmapSession.sessionUrl,
        credentials: newCredentials,
      );
    } on JmapRepositoryException catch (e) {
      return left(e.mapToAppFailure());
    }

    try {
      final newAccount = account.copyWith(
        jmapSession: newJmapSession,
        credentials: newCredentials,
      );
      await _accountRepository.save(newAccount);
      return right(newAccount);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}

class RefreshAndSetActiveAccountUsecase extends UsecaseBase<AccountId, void> {
  RefreshAndSetActiveAccountUsecase({
    required ActiveAccountRepository activeAccountRepository,
    required RefreshAndGetAccountUsecase refreshAndGetAccountUsecase,
  }) : _refreshAndGetAccountUsecase = refreshAndGetAccountUsecase,
       _activeAccountRepository = activeAccountRepository;

  final ActiveAccountRepository _activeAccountRepository;
  final RefreshAndGetAccountUsecase _refreshAndGetAccountUsecase;

  @override
  Future<Either<AppFailure, void>> execute(AccountId id) async {
    final refreshResult = await _refreshAndGetAccountUsecase.execute(id);
    switch (refreshResult) {
      case Left(:final value):
        return left(value);
      case Right(:final value):
        if (value == null) {
          return left(NotFoundFailure('Account with id ${id.value} not found'));
        }
    }

    try {
      await _activeAccountRepository.setActiveAccountId(id);
      return right(null);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}

class RemoveAccountUsecase extends UsecaseBase<AccountId, void> {
  RemoveAccountUsecase({
    required AccountRepository accountRepository,
    required ActiveAccountRepository activeAccountRepository,
  }) : _accountRepository = accountRepository,
       _activeAccountRepository = activeAccountRepository;

  final AccountRepository _accountRepository;
  final ActiveAccountRepository _activeAccountRepository;

  @override
  Future<Either<AppFailure, void>> execute(AccountId id) async {
    try {
      final activeAccountId = await _activeAccountRepository
          .getActiveAccountId();
      if (activeAccountId == id) {
        await _activeAccountRepository.clear();
      }
      await _accountRepository.delete(id);
      return right(null);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}

typedef AddAccountUsecaseInput = ({
  AccountId accountId,
  Credentials credentials,
  Uri jmapSessionEndpoint,
});

class AddAccountUsecase extends UsecaseBase<AddAccountUsecaseInput, void> {
  AddAccountUsecase({
    required JmapRepository jmapRepository,
    required AccountRepository accountRepository,
    required ActiveAccountRepository activeAccountRepository,
  }) : _accountRepository = accountRepository,
       _activeAccountRepository = activeAccountRepository,
       _jmapRepository = jmapRepository;

  final AccountRepository _accountRepository;
  final ActiveAccountRepository _activeAccountRepository;
  final JmapRepository _jmapRepository;

  @override
  Future<Either<AppFailure, void>> execute(AddAccountUsecaseInput input) async {
    final JmapSession jmapSession;
    try {
      jmapSession = await _jmapRepository.fetchSession(
        jmapSessionEndpoint: input.jmapSessionEndpoint,
        credentials: input.credentials,
      );
    } on JmapRepositoryException catch (e) {
      return left(e.mapToAppFailure());
    }
    final account = Account(
      id: input.accountId,
      credentials: input.credentials,
      jmapSession: jmapSession,
    );
    try {
      await _accountRepository.save(account);
      await _activeAccountRepository.setActiveAccountId(account.id);
      return right(null);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}
