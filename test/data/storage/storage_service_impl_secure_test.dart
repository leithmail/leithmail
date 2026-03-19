import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leithmail/core/services/storage_service.dart';
import 'package:leithmail/data/storage_service_impl_secure.dart';

import 'storage_service_contract_test_def.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _StorageServiceImplSecureTest().runTests();
}

class _StorageServiceImplSecureTest extends StorageServiceContractTestDef {
  @override
  StorageService createStorage(String namespace) =>
      StorageServiceImplSecure(namespace, const FlutterSecureStorage());

  @override
  void runTests() {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });
    super.runTests();
  }
}
