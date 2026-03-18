import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:leithmail/core/services/storage.dart';
import 'package:leithmail/data/account_repository_impl.dart';
import 'package:leithmail/data/active_account_repository_impl.dart';
import 'package:leithmail/data/storage_impl_local.dart';
import 'package:leithmail/data/storage_impl_memory.dart';
import 'package:leithmail/data/storage_impl_secure.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> applyAppBindings() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.put<Storage>(
    StorageImplSecure(const FlutterSecureStorage()),
    tag: 'secure',
    permanent: true,
  );
  Get.put<Storage>(
    StorageImplLocal(sharedPreferences),
    tag: 'local',
    permanent: true,
  );
  Get.put<Storage>(StorageImplMemory(), tag: 'memory', permanent: true);

  Get.put<AccountRepository>(
    AccountRepositoryImpl(
      persistent: Get.find<Storage>(tag: 'secure'),
      cache: Get.find<Storage>(tag: 'memory'),
    ),
    permanent: true,
  );
  Get.put<ActiveAccountRepository>(
    ActiveAccountRepositoryImpl(
      persistent: Get.find<Storage>(tag: 'local'),
      cache: Get.find<Storage>(tag: 'memory'),
    ),
    permanent: true,
  );
}
