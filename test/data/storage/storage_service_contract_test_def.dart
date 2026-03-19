import 'package:flutter_test/flutter_test.dart';
import 'package:leithmail/core/services/storage_service.dart';

abstract class StorageServiceContractTestDef {
  StorageService createStorage(String namespace);

  void runTests() {
    late StorageService storage;

    setUp(() {
      storage = createStorage('namespace1');
    });

    group('read/write', () {
      test('write and read returns value', () async {
        await storage.write('key', 'value');
        expect(await storage.read('key'), 'value');
      });

      test('read returns null for missing key', () async {
        expect(await storage.read('missing'), isNull);
      });

      test('write overwrites existing value', () async {
        await storage.write('key', 'value1');
        await storage.write('key', 'value2');
        expect(await storage.read('key'), 'value2');
      });
    });

    group('delete', () {
      test('delete removes key', () async {
        await storage.write('key', 'value');
        await storage.delete('key');
        expect(await storage.read('key'), isNull);
      });

      test('delete non-existing key does not throw', () async {
        expect(() => storage.delete('missing'), returnsNormally);
      });
    });

    group('readAll', () {
      test('returns all written keys', () async {
        await storage.write('key1', 'value1');
        await storage.write('key2', 'value2');
        expect(await storage.readAll(), {'key1': 'value1', 'key2': 'value2'});
      });

      test('returns empty map when nothing written', () async {
        expect(await storage.readAll(), isEmpty);
      });

      test('readAll returns unmodifiable map', () async {
        await storage.write('key', 'value');
        final all = await storage.readAll();
        expect(() => all['key'] = 'modified', throwsUnsupportedError);
      });
    });

    group('deleteAll', () {
      test('deletes all keys', () async {
        await storage.write('key1', 'value1');
        await storage.write('key2', 'value2');
        await storage.deleteAll();
        expect(await storage.readAll(), isEmpty);
      });

      test('deleteAll does not throw when empty', () async {
        expect(() => storage.deleteAll(), returnsNormally);
      });
    });

    group('isolation', () {
      test('two instances do not share state', () async {
        final other = createStorage("namespace2");
        await storage.write('key', 'value');
        expect(await other.read('key'), isNull);
        expect(await storage.read('key'), 'value');
      });
    });
  }
}
