import 'package:leithmail/core/services/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageImplLocal implements Storage {
  final SharedPreferences _prefs;

  const StorageImplLocal(this._prefs);

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> delete(String key) => _prefs.remove(key);

  @override
  Future<Map<String, String>> readAll() async => Map.fromEntries(
    _prefs.getKeys().map((k) => MapEntry(k, _prefs.getString(k) ?? '')),
  );

  @override
  Future<void> deleteAll() => _prefs.clear();
}
