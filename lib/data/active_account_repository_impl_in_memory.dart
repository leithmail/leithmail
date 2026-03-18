import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';

class ActiveAccountRepositoryImplInMemory implements ActiveAccountRepository {
  AccountId? _activeAccountId;

  @override
  Future<AccountId?> getActiveAccountId() async => _activeAccountId;

  @override
  Future<void> setActiveAccountId(AccountId id) async => _activeAccountId = id;

  @override
  Future<void> clear() async => _activeAccountId = null;
}
