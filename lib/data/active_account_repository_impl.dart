import 'package:leithmail/core/services/storage.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';

class ActiveAccountRepositoryImpl implements ActiveAccountRepository {
  final Storage _persistent;
  final Storage _cache;

  static const _key = 'active_account_id';

  ActiveAccountRepositoryImpl({
    required Storage persistent,
    required Storage cache,
  }) : _persistent = persistent,
       _cache = cache;

  @override
  Future<AccountId?> getActiveAccountId() async {
    final cached = await _cache.read(_key);
    if (cached != null) return AccountId(cached);
    final value = await _persistent.read(_key);
    if (value == null) return null;
    await _cache.write(_key, value);
    return AccountId(value);
  }

  @override
  Future<void> setActiveAccountId(AccountId id) async {
    await _cache.write(_key, id.value);
    await _persistent.write(_key, id.value);
  }

  @override
  Future<void> clear() async {
    await _cache.delete(_key);
    await _persistent.delete(_key);
  }
}
