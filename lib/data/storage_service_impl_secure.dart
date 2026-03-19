import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:leithmail/core/services/storage_service.dart';

class StorageServiceImplSecure extends StorageService
    with StorageNamespacedKey {
  final FlutterSecureStorage _storage;

  @override
  final String namespace;

  StorageServiceImplSecure(this.namespace, this._storage);

  @override
  Future<String?> read(String key) => _storage.read(key: namespacedKey(key));

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: namespacedKey(key), value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: namespacedKey(key));

  @override
  Future<Map<String, String>> readAll() async {
    final all = await _storage.readAll();
    return Map.fromEntries(
      all.entries
          .where((e) => e.key.startsWith('$namespace:'))
          .map((e) => MapEntry(e.key.substring('$namespace:'.length), e.value)),
    );
  }

  @override
  Future<void> deleteAll() async {
    final all = await _storage.readAll();
    final keys = all.keys
        .where((k) => k.startsWith('$namespace:'))
        .toList();
    for (final key in keys) {
      await _storage.delete(key: key);
    }
  }
}
