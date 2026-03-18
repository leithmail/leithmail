import 'package:get/get.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';
import 'package:leithmail/presentation/dashboard/dashboard_controller.dart';

class DashboardBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => DashboardController(
        Get.find<AccountRepository>(),
        Get.find<ActiveAccountRepository>(),
      ),
    );
  }
}
