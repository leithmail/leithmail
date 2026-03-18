import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';

class AccountRepositoryImplInMemory implements AccountRepository {
  final Map<AccountId, Account> _accounts = {};

  @override
  Future<List<Account>> getAll() async => _accounts.values.toList();

  @override
  Future<Account?> getById(AccountId id) async => _accounts[id];

  @override
  Future<void> save(Account account) async => _accounts[account.id] = account;

  @override
  Future<void> delete(AccountId id) async => _accounts.remove(id);
}
