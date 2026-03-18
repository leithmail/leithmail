import 'package:leithmail/domain/entities/account.dart';

abstract class ActiveAccountRepository {
  Future<AccountId?> getActiveAccountId();
  Future<void> setActiveAccountId(AccountId id);
  Future<void> clear();
}
