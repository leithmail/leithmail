import 'package:leithmail/core/services/storage_service.dart';

abstract class StorageServiceFactory {
  StorageService secure(String namespace);
  StorageService local(String namespace);
  StorageService memory(String namespace);
}
