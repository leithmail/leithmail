import 'package:leithmail/core/services/storage_service.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';

class ActiveAccountRepositoryImpl implements ActiveAccountRepository {
  final StorageService _persistent;

  AccountId? _activeAccountId;
  static const String _activeAccountIdStorageKey = 'id';

  ActiveAccountRepositoryImpl({required StorageService persistent})
    : _persistent = persistent;

  @override
  Future<AccountId?> getActiveAccountId() async {
    if (_activeAccountId == null) {
      final value = await _persistent.read(_activeAccountIdStorageKey);
      _activeAccountId = value != null ? AccountId(value) : null;
    }
    return _activeAccountId;
  }

  @override
  Future<void> setActiveAccountId(AccountId id) async {
    _activeAccountId = id;
    await _persistent.write(_activeAccountIdStorageKey, id.value);
  }

  @override
  Future<void> clear() async {
    _activeAccountId = null;
    await _persistent.delete(_activeAccountIdStorageKey);
  }
}
