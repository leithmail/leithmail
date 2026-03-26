import 'package:fpdart/fpdart.dart';
import 'package:leithmail/core/usecase/app_failure.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';

class GetActiveAccountUsecase extends UsecaseBase<NoInput, Account?> {
  GetActiveAccountUsecase(this._accountRepo, this._activeRepo);

  final AccountRepository _accountRepo;
  final ActiveAccountRepository _activeRepo;

  @override
  Future<Either<AppFailure, Account?>> execute(NoInput _) async {
    try {
      final id = await _activeRepo.getActiveAccountId();
      if (id == null) return right(null);
      final account = await _accountRepo.getById(id);
      return right(account);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}

class GetAllAccountsUsecase extends UsecaseBase<NoInput, List<Account>> {
  GetAllAccountsUsecase(this._accountRepo);

  final AccountRepository _accountRepo;

  @override
  Future<Either<AppFailure, List<Account>>> execute(NoInput _) async {
    try {
      final accounts = await _accountRepo.getAll();
      return right(accounts);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}

class GetAuthenticatedAccountUsecase extends UsecaseBase<AccountId, Account?> {
  final AccountRepository _repository;
  GetAuthenticatedAccountUsecase(this._repository);

  @override
  Future<Either<AppFailure, Account?>> execute(AccountId id) async {
    final Account? account;
    try {
      account = await _repository.getById(id);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
    if (account == null) {
      return right(null);
    }
    if (account.credentials.isExpired) {
      return right(null);
    }
    return right(account);
  }
}

class SetActiveAccountUsecase extends UsecaseBase<AccountId, void> {
  SetActiveAccountUsecase(this._activeRepo);

  final ActiveAccountRepository _activeRepo;

  @override
  Future<Either<AppFailure, void>> execute(AccountId id) async {
    try {
      await _activeRepo.setActiveAccountId(id);
      return right(null);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}

class AddAccountUsecase extends UsecaseBase<Account, void> {
  AddAccountUsecase(this._accountRepo, this._activeRepo);

  final AccountRepository _accountRepo;
  final ActiveAccountRepository _activeRepo;

  @override
  Future<Either<AppFailure, void>> execute(Account account) async {
    try {
      await _accountRepo.save(account);
      await _activeRepo.setActiveAccountId(account.id);
      return right(null);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}

class RemoveAccountUsecase extends UsecaseBase<AccountId, void> {
  RemoveAccountUsecase(this._accountRepo, this._activeRepo);

  final AccountRepository _accountRepo;
  final ActiveAccountRepository _activeRepo;

  @override
  Future<Either<AppFailure, void>> execute(AccountId id) async {
    try {
      await _accountRepo.delete(id);
      final remaining = await _accountRepo.getAll();
      if (remaining.isEmpty) {
        await _activeRepo.clear();
      } else {
        await _activeRepo.setActiveAccountId(remaining.first.id);
      }
      return right(null);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}
