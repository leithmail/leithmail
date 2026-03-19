import 'package:flutter_test/flutter_test.dart';
import 'package:leithmail/core/services/storage_service.dart';
import 'package:leithmail/data/storage_service_impl_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service_contract_test_def.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _StorageServiceImplLocalTest().runTests();
}

class _StorageServiceImplLocalTest extends StorageServiceContractTestDef {
  late SharedPreferences prefs;

  @override
  StorageService createStorage(String namespace) =>
      StorageServiceImplLocal(namespace, prefs);

  @override
  void runTests() {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });
    super.runTests();
  }
}
