import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:leithmail/core/services/storage_service_factory.dart';
import 'package:leithmail/data/account_repository_impl.dart';
import 'package:leithmail/data/active_account_repository_impl.dart';
import 'package:leithmail/data/storage_service_factory_impl.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> applyAppBindings() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  const flutterSecureStorage = FlutterSecureStorage();
  final storageServiceFactory = StorageServiceFactoryImpl(
    flutterSecureStorage: flutterSecureStorage,
    sharedPreferences: sharedPreferences,
  );

  Get.put<StorageServiceFactory>(storageServiceFactory, permanent: true);

  Get.put<AccountRepository>(
    AccountRepositoryImpl(
      persistent: storageServiceFactory.secure('account'),
      cache: storageServiceFactory.memory('account'),
    ),
    permanent: true,
  );
  Get.put<ActiveAccountRepository>(
    ActiveAccountRepositoryImpl(
      persistent: storageServiceFactory.local('active_account'),
    ),
    permanent: true,
  );
}
