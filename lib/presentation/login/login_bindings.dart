import 'package:get/get.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';
import 'package:leithmail/presentation/login/login_controller.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => LoginController(
        Get.find<AccountRepository>(),
        Get.find<ActiveAccountRepository>(),
      ),
    );
  }
}
