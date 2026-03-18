import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:leithmail/core/services/storage_service.dart';
import 'package:leithmail/data/account_repository_impl.dart';
import 'package:leithmail/data/active_account_repository_impl.dart';
import 'package:leithmail/data/storage_service_impl_local.dart';
import 'package:leithmail/data/storage_service_impl_memory.dart';
import 'package:leithmail/data/storage_service_impl_secure.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> applyAppBindings() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.put<StorageService>(
    StorageServiceImplSecure(const FlutterSecureStorage()),
    tag: StorageServiceTag.secure.toString(),
    permanent: true,
  );
  Get.put<StorageService>(
    StorageServiceImplLocal(sharedPreferences),
    tag: StorageServiceTag.local.toString(),
    permanent: true,
  );
  Get.put<StorageService>(
    StorageServiceImplMemory(),
    tag: StorageServiceTag.memory.toString(),
    permanent: true,
  );

  Get.put<AccountRepository>(
    AccountRepositoryImpl(
      persistent: Get.find<StorageService>(
        tag: StorageServiceTag.secure.toString(),
      ),
      cache: Get.find<StorageService>(tag: StorageServiceTag.memory.toString()),
    ),
    permanent: true,
  );
  Get.put<ActiveAccountRepository>(
    ActiveAccountRepositoryImpl(
      persistent: Get.find<StorageService>(
        tag: StorageServiceTag.local.toString(),
      ),
      cache: Get.find<StorageService>(tag: StorageServiceTag.memory.toString()),
    ),
    permanent: true,
  );
}

enum StorageServiceTag { secure, local, memory }
