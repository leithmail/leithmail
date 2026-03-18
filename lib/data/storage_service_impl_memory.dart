import 'package:leithmail/core/services/storage_service.dart';

class StorageServiceImplMemory extends StorageService {
  final Map<String, String> _store = {};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<Map<String, String>> readAll() async => Map.unmodifiable(_store);

  @override
  Future<void> deleteAll() async => _store.clear();
}
