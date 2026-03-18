import 'package:leithmail/domain/entities/account.dart';

abstract class AccountRepository {
  Future<List<Account>> getAll();
  Future<Account?> getById(AccountId id);
  Future<void> save(Account account);
  Future<void> delete(AccountId id);
}
