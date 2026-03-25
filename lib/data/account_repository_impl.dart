import 'package:leithmail/core/logging/log.dart';
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
          .map((entry) => _tryDeserializeAccount(entry.value, entry.key))
          .nonNulls
          .toList();
    }
    final storedAccountsSerialized = await _persistent.readAll();
    final deserializedAccounts = storedAccountsSerialized.entries
        .map((entry) => _tryDeserializeAccount(entry.value, entry.key))
        .nonNulls
        .toList();

    for (final account in deserializedAccounts) {
      await _cache.write(account.id.value, account.serialize());
    }
    _cacheHydrated = true;
    return deserializedAccounts;
  }

  @override
  Future<Account?> getById(AccountId id) async {
    final cachedAccountSerialized = await _cache.read(id.value);
    if (cachedAccountSerialized != null) {
      return _tryDeserializeAccount(cachedAccountSerialized, id.value);
    }
    final storedAccountSerialized = await _persistent.read(id.value);
    if (storedAccountSerialized == null) {
      return null;
    }

    final deserializedAccount = _tryDeserializeAccount(
      storedAccountSerialized,
      id.value,
    );
    if (deserializedAccount != null) {
      await _cache.write(id.value, deserializedAccount.serialize());
    }
    return deserializedAccount;
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

  Account? _tryDeserializeAccount(String data, String accountLabel) {
    try {
      return Account.deserialize(data);
    } catch (e) {
      Log.warning('[$runtimeType] undeserializable account: $accountLabel');
      return null;
    }
  }
}
