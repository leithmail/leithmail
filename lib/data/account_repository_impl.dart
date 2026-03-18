import 'package:leithmail/core/services/storage_service.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final StorageService _persistent;
  final StorageService _cache;

  bool _cacheHydrated = false;

  AccountRepositoryImpl({
    required StorageService persistent,
    required StorageService cache,
  }) : _persistent = persistent,
       _cache = cache;

  @override
  Future<List<Account>> getAll() async {
    if (_cacheHydrated) {
      final cachedAccountsSerialized = await _cache.readAll();
      return cachedAccountsSerialized.entries
          .map((e) => Account.deserialize(e.value))
          .toList();
    }
    final storedAccountsSerialized = await _persistent.readAll();
    for (final entry in storedAccountsSerialized.entries) {
      await _cache.write(entry.key, entry.value);
    }
    _cacheHydrated = true;
    return storedAccountsSerialized.entries
        .map((e) => Account.deserialize(e.value))
        .toList();
  }

  @override
  Future<Account?> getById(AccountId id) async {
    final cachedAccountSerialized = await _cache.read(id.value);
    if (cachedAccountSerialized != null) {
      return Account.deserialize(cachedAccountSerialized);
    }
    final storedAccountSerialized = await _persistent.read(id.value);
    if (storedAccountSerialized != null) {
      await _cache.write(id.value, storedAccountSerialized);
      return Account.deserialize(storedAccountSerialized);
    }
    return null;
  }

  @override
  Future<void> save(Account account) async {
    final accountSerialized = account.serialize();
    await _cache.write(account.id.value, accountSerialized);
    await _persistent.write(account.id.value, accountSerialized);
  }

  @override
  Future<void> delete(AccountId id) async {
    await _cache.delete(id.value);
    await _persistent.delete(id.value);
  }
}
