import 'package:flutter_test/flutter_test.dart';
import 'package:leithmail/data/active_account_repository_impl.dart';
import 'package:leithmail/data/storage_service_impl_memory.dart';
import 'package:leithmail/domain/entities/account.dart';

void main() {
  late ActiveAccountRepositoryImpl repository;
  late StorageServiceImplMemory storage;

  setUp(() {
    storage = StorageServiceImplMemory();
    repository = ActiveAccountRepositoryImpl(persistent: storage);
  });

  group('getActiveAccountId', () {
    test('returns null when no active account set', () async {
      expect(await repository.getActiveAccountId(), isNull);
    });

    test('returns account id after set', () async {
      final id = AccountId('test@example.com');
      await repository.setActiveAccountId(id);
      expect(await repository.getActiveAccountId(), id);
    });

    test('reads from persistent storage on first call', () async {
      await storage.write('id', 'test@example.com');
      expect(
        await repository.getActiveAccountId(),
        AccountId('test@example.com'),
      );
    });

    test('returns cached value on subsequent calls', () async {
      final id = AccountId('test@example.com');
      await repository.setActiveAccountId(id);
      await storage.deleteAll(); // wipe storage
      // should still return cached value
      expect(await repository.getActiveAccountId(), id);
    });
  });

  group('setActiveAccountId', () {
    test('persists to storage', () async {
      final id = AccountId('test@example.com');
      await repository.setActiveAccountId(id);
      expect(await storage.read('id'), 'test@example.com');
    });

    test('overwrites previous value', () async {
      await repository.setActiveAccountId(AccountId('first@example.com'));
      await repository.setActiveAccountId(AccountId('second@example.com'));
      expect(
        await repository.getActiveAccountId(),
        AccountId('second@example.com'),
      );
    });
  });

  group('clear', () {
    test('returns null after clear', () async {
      await repository.setActiveAccountId(AccountId('test@example.com'));
      await repository.clear();
      expect(await repository.getActiveAccountId(), isNull);
    });

    test('removes from persistent storage', () async {
      await repository.setActiveAccountId(AccountId('test@example.com'));
      await repository.clear();
      expect(await storage.read('id'), isNull);
    });

    test('clear on empty does not throw', () async {
      expect(() => repository.clear(), returnsNormally);
    });
  });
}
