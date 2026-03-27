import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/jmap_session.dart';

void main() {
  group('copyWith', () {
    test('copyWith returns new instance', () {
      final account = Account.mock();
      final copy = account.copyWith();
      expect(identical(account, copy), isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      final account = Account.mock();
      final copy = account.copyWith();
      expect(copy.id, account.id);
      expect(copy.jmapSession.apiUrl, account.jmapSession.apiUrl);
    });

    test('copyWith replaces credentials', () {
      final account = Account.mock(
        credentials: OidcCredentials.mock(accessToken: 'token'),
      );
      final newCredentials = OidcCredentials.mock(accessToken: 'new_token');
      final copy = account.copyWith(credentials: newCredentials);
      expect(copy.credentials.toAuthorizationHeader(), 'Bearer new_token');
      expect(account.credentials.toAuthorizationHeader(), 'Bearer token');
    });

    test('copyWith replaces jmapSession', () {
      final account = Account.mock(
        jmapSession: JmapSession.mock(
          apiUrl: Uri.parse('https://old.example.com'),
        ),
      );
      final newJmap = JmapSession.mock(
        apiUrl: Uri.parse('https://new.example.com'),
      );
      final copy = account.copyWith(jmapSession: newJmap);
      expect(copy.jmapSession.apiUrl, Uri.parse('https://new.example.com'));
      expect(account.jmapSession.apiUrl, Uri.parse('https://old.example.com'));
    });
  });

  group('serialization', () {
    test('serialize and deserialize roundtrip', () {
      final account = Account.mock();
      final deserialized = Account.deserialize(account.serialize());
      expect(deserialized.id.toString(), account.id.toString());
      expect(deserialized.jmapSession.apiUrl, account.jmapSession.apiUrl);
      expect(deserialized.credentials, isA<OidcCredentials>());
    });

    test('credentials type is preserved', () {
      final account = Account.mock(
        credentials: OidcCredentials.mock(accessToken: 'token'),
      );
      final deserialized = Account.deserialize(account.serialize());
      final credentials = deserialized.credentials as OidcCredentials;
      expect(credentials.accessToken, 'token');
    });

    test('jmap urls are preserved', () {
      final account = Account.mock();
      final deserialized = Account.deserialize(account.serialize());
      expect(deserialized.jmapSession.apiUrl, account.jmapSession.apiUrl);
      expect(
        deserialized.jmapSession.downloadUrl,
        account.jmapSession.downloadUrl,
      );
      expect(deserialized.jmapSession.uploadUrl, account.jmapSession.uploadUrl);
      expect(
        deserialized.jmapSession.eventSourceUrl,
        account.jmapSession.eventSourceUrl,
      );
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
