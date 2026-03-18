import 'package:get/get.dart';
import 'package:leithmail/data/account_repository_impl_in_memory.dart';
import 'package:leithmail/data/active_account_repository_impl_in_memory.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AccountRepository>(
      AccountRepositoryImplInMemory(),
      permanent: true,
    );
    Get.put<ActiveAccountRepository>(
      ActiveAccountRepositoryImplInMemory(),
      permanent: true,
    );
  }
}
