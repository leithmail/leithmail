import 'package:get/get.dart';
import 'package:leithmail/core/error/failure.dart';

abstract class BaseController extends GetxController {
  void handleFailure(Failure failure) {
    Get.snackbar('Error', failure.exception.toString());
  }
}
