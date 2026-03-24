import 'package:flutter_test/flutter_test.dart';
import 'package:leithmail/data/account_repository_impl.dart';
import 'package:leithmail/data/storage_service_impl_memory.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/credentials.dart';

void main() {
  late AccountRepositoryImpl repository;
  late StorageServiceImplMemory persistent;
  late StorageServiceImplMemory cache;

  setUp(() {
    persistent = StorageServiceImplMemory();
    cache = StorageServiceImplMemory();
    repository = AccountRepositoryImpl(persistent: persistent, cache: cache);
  });

  group('save', () {
    test('saves to both persistent and cache', () async {
      final account = Account.mock(email: 'test@example.com');
      await repository.save(account);
      expect(await persistent.read(account.id.value), isNotNull);
      expect(await cache.read(account.id.value), isNotNull);
    });

    test('saved account can be retrieved', () async {
      final account = Account.mock(email: 'test@example.com');
      await repository.save(account);
      final retrieved = await repository.getById(account.id);
      expect(
        retrieved?.emailAddress.toString(),
        account.emailAddress.toString(),
      );
    });

    test('save overwrites existing account', () async {
      final account = Account.mock(email: 'test@example.com');
      await repository.save(account);

      final retrieved1 = await repository.getById(account.id);
      expect((retrieved1?.credentials as CredentialsOidc).accessToken, 'token');

      final updated = account.copyWith(
        credentials: CredentialsOidc(
          accessToken: 'new_token',
          refreshToken: 'new_refresh',
          expiry: DateTime(2027),
          clientId: 'leithmail_mock',
          tokenEndpoint: Uri(),
        ),
      );
      await repository.save(updated);

      final retrieved2 = await repository.getById(account.id);
      expect(
        (retrieved2?.credentials as CredentialsOidc).accessToken,
        'new_token',
      );
    });

    test('overwrite is reflected in getAll', () async {
      final account = Account.mock(email: 'test@example.com');
      await repository.save(account);

      final updated = account.copyWith(
        credentials: CredentialsOidc(
          accessToken: 'new_token',
          refreshToken: 'new_refresh',
          expiry: DateTime(2027),
          clientId: 'leithmail_mock',
          tokenEndpoint: Uri(),
        ),
      );
      await repository.save(updated);

      final all = await repository.getAll();
      expect(all.length, 1);
      expect(
        (all.first.credentials as CredentialsOidc).accessToken,
        'new_token',
      );
    });
  });

  group('getById', () {
    test('returns null for missing account', () async {
      expect(
        await repository.getById(AccountId('missing@example.com')),
        isNull,
      );
    });

    test('returns account from cache if available', () async {
      final account = Account.mock(email: 'test@example.com');
      await repository.save(account);
      await persistent.deleteAll(); // wipe persistent
      final retrieved = await repository.getById(account.id);
      expect(retrieved, isNotNull);
    });

    test('falls back to persistent if not in cache', () async {
      final account = Account.mock(email: 'test@example.com');
      await persistent.write(account.id.value, account.serialize());
      final retrieved = await repository.getById(account.id);
      expect(
        retrieved?.emailAddress.toString(),
        account.emailAddress.toString(),
      );
    });

    test('caches account after reading from persistent', () async {
      final account = Account.mock(email: 'test@example.com');
      await persistent.write(account.id.value, account.serialize());
      await repository.getById(
        account.id,
      ); // first call — reads from persistent
      await persistent.deleteAll(); // wipe persistent
      final retrieved = await repository.getById(
        account.id,
      ); // second call — from cache
      expect(retrieved, isNotNull);
    });
  });

  group('getAll', () {
    test('returns empty list when no accounts', () async {
      expect(await repository.getAll(), isEmpty);
    });

    test('returns all saved accounts', () async {
      await repository.save(Account.mock(email: 'first@example.com'));
      await repository.save(Account.mock(email: 'second@example.com'));
      final accounts = await repository.getAll();
      expect(accounts.length, 2);
    });

    test('reads from persistent on first call', () async {
      final account = Account.mock(email: 'test@example.com');
      await persistent.write(account.id.value, account.serialize());
      final accounts = await repository.getAll();
      expect(accounts.length, 1);
    });

    test('reads from cache on subsequent calls', () async {
      final account = Account.mock(email: 'test@example.com');
      await repository.save(account);
      await repository.getAll(); // hydrates cache
      await persistent.deleteAll(); // wipe persistent
      final accounts = await repository.getAll(); // should use cache
      expect(accounts.length, 1);
    });

    test('cache is hydrated after first getAll', () async {
      await repository.save(Account.mock(email: 'test@example.com'));
      await repository.getAll(); // hydrates cache
      await persistent.deleteAll();
      expect(await repository.getAll(), isNotEmpty);
    });
  });

  group('delete', () {
    test('removes from both persistent and cache', () async {
      final account = Account.mock(email: 'test@example.com');
      await repository.save(account);
      await repository.delete(account.id);
      expect(await persistent.read(account.id.value), isNull);
      expect(await cache.read(account.id.value), isNull);
    });

    test('returns null after delete', () async {
      final account = Account.mock(email: 'test@example.com');
      await repository.save(account);
      await repository.delete(account.id);
      expect(await repository.getById(account.id), isNull);
    });

    test('delete non-existing account does not throw', () async {
      expect(
        () => repository.delete(AccountId('missing@example.com')),
        returnsNormally,
      );
    });
  });

  group('serialization roundtrip', () {
    test('account survives serialize/deserialize', () async {
      final account = Account.mock(email: 'test@example.com');
      await repository.save(account);
      final retrieved = await repository.getById(account.id);
      expect(
        retrieved?.emailAddress.toString(),
        account.emailAddress.toString(),
      );
      expect(retrieved?.credentials, isA<CredentialsOidc>());
      expect(retrieved?.jmap.apiUrl, account.jmap.apiUrl);
    });
  });
}
