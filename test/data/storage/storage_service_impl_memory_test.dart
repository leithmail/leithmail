import 'package:leithmail/core/services/storage_service.dart';
import 'package:leithmail/data/storage_service_impl_memory.dart';

import 'storage_service_contract_test_def.dart';

void main() {
  _StorageServiceImplMemoryTest().runTests();
}

class _StorageServiceImplMemoryTest extends StorageServiceContractTestDef {
  @override
  StorageService createStorage(String namespace) => StorageServiceImplMemory();
}
