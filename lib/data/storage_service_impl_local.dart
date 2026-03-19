import 'package:leithmail/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServiceImplLocal extends StorageService with StorageNamespacedKey {
  final SharedPreferences _prefs;

  @override
  final String namespace;

  StorageServiceImplLocal(this.namespace, this._prefs);

  @override
  Future<String?> read(String key) async =>
      _prefs.getString(namespacedKey(key));

  @override
  Future<void> write(String key, String value) =>
      _prefs.setString(namespacedKey(key), value);

  @override
  Future<void> delete(String key) => _prefs.remove(namespacedKey(key));
  @override
  Future<Map<String, String>> readAll() async {
    final entries = _prefs
        .getKeys()
        .where((k) => k.startsWith('$namespace:'))
        .map(
          (k) => (
            key: k.substring('$namespace:'.length),
            value: _prefs.getString(k),
          ),
        )
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value!));
    return Map.unmodifiable(Map.fromEntries(entries));
  }

  @override
  Future<void> deleteAll() async {
    final keys = _prefs
        .getKeys()
        .where((k) => k.startsWith('$namespace:'))
        .toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
