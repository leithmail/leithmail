import 'dart:convert';
import 'package:leithmail/core/services/storage_service.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final StorageService _persistent;
  final StorageService _cache;

  static const _keyPrefix = 'account:';

  AccountRepositoryImpl({
    required StorageService persistent,
    required StorageService cache,
  }) : _persistent = persistent,
       _cache = cache;

  @override
  Future<List<Account>> getAll() async {
    final all = await _persistent.readAll();
    return all.entries
        .where((e) => e.key.startsWith(_keyPrefix))
        .map((e) => Account.fromJson(jsonDecode(e.value)))
        .toList();
  }

  @override
  Future<Account?> getById(AccountId id) async {
    final cached = await _cache.read('$_keyPrefix${id.value}');
    if (cached != null) return Account.fromJson(jsonDecode(cached));
    final raw = await _persistent.read('$_keyPrefix${id.value}');
    if (raw == null) return null;
    await _cache.write('$_keyPrefix${id.value}', raw);
    return Account.fromJson(jsonDecode(raw));
  }

  @override
  Future<void> save(Account account) async {
    final raw = jsonEncode(account.toJson());
    await _cache.write('$_keyPrefix${account.id.value}', raw);
    await _persistent.write('$_keyPrefix${account.id.value}', raw);
  }

  @override
  Future<void> delete(AccountId id) async {
    await _cache.delete('$_keyPrefix${id.value}');
    await _persistent.delete('$_keyPrefix${id.value}');
  }
}
