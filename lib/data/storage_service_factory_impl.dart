import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:leithmail/core/services/storage_service.dart';
import 'package:leithmail/core/services/storage_service_factory.dart';
import 'package:leithmail/data/storage_service_impl_local.dart';
import 'package:leithmail/data/storage_service_impl_memory.dart';
import 'package:leithmail/data/storage_service_impl_secure.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServiceFactoryImpl implements StorageServiceFactory {
  final FlutterSecureStorage _flutterSecureStorage;
  final SharedPreferences _sharedPreferences;

  const StorageServiceFactoryImpl({
    required FlutterSecureStorage flutterSecureStorage,
    required SharedPreferences sharedPreferences,
  }) : _flutterSecureStorage = flutterSecureStorage,
       _sharedPreferences = sharedPreferences;

  @override
  StorageService secure(String namespace) =>
      StorageServiceImplSecure(namespace, _flutterSecureStorage);

  @override
  StorageService local(String namespace) =>
      StorageServiceImplLocal(namespace, _sharedPreferences);

  @override
  StorageService memory(String namespace) => StorageServiceImplMemory(); // namespace unused in memory implementation, each instance has its own namespace
}
