import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/jmap_metadata.dart';

void main() {
  group('id', () {
    test('id is derived from email address', () {
      final account = Account.mock(email: 'test@example.com');
      expect(account.id, AccountId('test@example.com'));
    });

    test('accounts with same email have same id', () {
      final a = Account.mock(email: 'test@example.com');
      final b = Account.mock(email: 'test@example.com');
      expect(a.id, b.id);
    });

    test('accounts with different emails have different ids', () {
      final a = Account.mock(email: 'first@example.com');
      final b = Account.mock(email: 'second@example.com');
      expect(a.id, isNot(b.id));
    });
  });

  group('copyWith', () {
    test('copyWith returns new instance', () {
      final account = Account.mock();
      final copy = account.copyWith();
      expect(identical(account, copy), isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      final account = Account.mock();
      final copy = account.copyWith();
      expect(copy.emailAddress, account.emailAddress);
      expect(copy.jmap.apiUrl, account.jmap.apiUrl);
    });

    test('copyWith replaces credentials', () {
      final account = Account.mock();
      final newCredentials = CredentialsOidc(
        accessToken: 'new_token',
        refreshToken: 'new_refresh',
        expiry: DateTime(2027),
      );
      final copy = account.copyWith(credentials: newCredentials);
      expect((copy.credentials as CredentialsOidc).accessToken, 'new_token');
      expect((account.credentials as CredentialsOidc).accessToken, 'token');
    });

    test('copyWith replaces jmap', () {
      final account = Account.mock();
      final newJmap = JmapMetadata(
        apiUrl: Uri.parse('https://new.example.com'),
        downloadUrl: Uri.parse('https://new.example.com/download'),
        uploadUrl: Uri.parse('https://new.example.com/upload'),
        eventSourceUrl: Uri.parse('https://new.example.com/events'),
      );
      final copy = account.copyWith(jmap: newJmap);
      expect(copy.jmap.apiUrl, Uri.parse('https://new.example.com'));
      expect(account.jmap.apiUrl, Uri.parse('https://jmap.example.com'));
    });
  });

  group('serialization', () {
    test('serialize and deserialize roundtrip', () {
      final account = Account.mock();
      final deserialized = Account.deserialize(account.serialize());
      expect(
        deserialized.emailAddress.toString(),
        account.emailAddress.toString(),
      );
      expect(deserialized.jmap.apiUrl, account.jmap.apiUrl);
      expect(deserialized.credentials, isA<CredentialsOidc>());
    });

    test('credentials type is preserved', () {
      final account = Account.mock();
      final deserialized = Account.deserialize(account.serialize());
      final credentials = deserialized.credentials as CredentialsOidc;
      expect(credentials.accessToken, 'token');
      expect(credentials.refreshToken, 'refresh');
      expect(credentials.expiry, DateTime(2026));
    });

    test('jmap urls are preserved', () {
      final account = Account.mock();
      final deserialized = Account.deserialize(account.serialize());
      expect(deserialized.jmap.apiUrl, account.jmap.apiUrl);
      expect(deserialized.jmap.downloadUrl, account.jmap.downloadUrl);
      expect(deserialized.jmap.uploadUrl, account.jmap.uploadUrl);
      expect(deserialized.jmap.eventSourceUrl, account.jmap.eventSourceUrl);
    });

    test('toJson includes type discriminator for credentials', () {
      final account = Account.mock();
      final json = account.toJson();
      expect((json['credentials'] as Map<String, dynamic>)['type'], 'oidc');
    });

    test('fromJson with unknown credentials type throws', () {
      final account = Account.mock();
      final json = account.toJson();
      (json['credentials'] as Map<String, dynamic>)['type'] = 'unknown';
      expect(
        () => Account.deserialize(jsonEncode(json)),
        throwsUnimplementedError,
      );
    });
  });
}
