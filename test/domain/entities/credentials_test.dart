import 'package:flutter_test/flutter_test.dart';
import 'package:leithmail/domain/entities/credentials.dart';

void main() {
  group('isExpired', () {
    test('returns false when expiry is in the future', () {
      final credentials = CredentialsOidc(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiry: DateTime.now().add(const Duration(hours: 1)),
        tokenEndpoint: Uri(),
        clientId: 'leithmail_mock',
      );
      expect(credentials.isExpired, isFalse);
    });

    test('returns true when expiry is in the past', () {
      final credentials = CredentialsOidc(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiry: DateTime.now().subtract(const Duration(hours: 1)),
        tokenEndpoint: Uri(),
        clientId: 'leithmail_mock',
      );
      expect(credentials.isExpired, isTrue);
    });

    test('returns true when expiry is exactly now', () {
      final expiry = DateTime.now().subtract(const Duration(milliseconds: 1));
      final credentials = CredentialsOidc(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiry: expiry,
        tokenEndpoint: Uri(),
        clientId: 'leithmail_mock',
      );
      expect(credentials.isExpired, isTrue);
    });
  });

  group('toAuthorizationHeader', () {
    test('returns bearer token', () {
      final credentials = CredentialsOidc(
        accessToken: 'my_access_token',
        refreshToken: 'refresh',
        expiry: DateTime.now().add(const Duration(hours: 1)),
        tokenEndpoint: Uri(),
        clientId: 'leithmail_mock',
      );
      expect(credentials.toAuthorizationHeader(), 'Bearer my_access_token');
    });

    test('header changes when access token changes', () {
      final a = CredentialsOidc(
        accessToken: 'token_a',
        refreshToken: 'refresh',
        expiry: DateTime.now().add(const Duration(hours: 1)),
        tokenEndpoint: Uri(),
        clientId: 'leithmail_mock',
      );
      final b = CredentialsOidc(
        accessToken: 'token_b',
        refreshToken: 'refresh',
        expiry: DateTime.now().add(const Duration(hours: 1)),
        tokenEndpoint: Uri(),
        clientId: 'leithmail_mock',
      );
      expect(a.toAuthorizationHeader(), isNot(b.toAuthorizationHeader()));
    });
  });

  group('serialization', () {
    test('toJson and fromJson roundtrip', () {
      final credentials = CredentialsOidc(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiry: DateTime(2026),
        tokenEndpoint: Uri(),
        clientId: 'leithmail_mock',
      );
      final deserialized = CredentialsOidc.fromJson(credentials.toJson());
      expect(deserialized.accessToken, credentials.accessToken);
      expect(deserialized.refreshToken, credentials.refreshToken);
      expect(deserialized.expiry, credentials.expiry);
    });

    test('expiry is preserved after serialization', () {
      final expiry = DateTime(2026, 3, 19, 12, 0, 0);
      final credentials = CredentialsOidc(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiry: expiry,
        tokenEndpoint: Uri(),
        clientId: 'leithmail_mock',
      );
      final deserialized = CredentialsOidc.fromJson(credentials.toJson());
      expect(deserialized.expiry, expiry);
    });

    test('isExpired is preserved after serialization', () {
      final expired = CredentialsOidc(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiry: DateTime.now().subtract(const Duration(hours: 1)),
        tokenEndpoint: Uri(),
        clientId: 'leithmail_mock',
      );
      final deserialized = CredentialsOidc.fromJson(expired.toJson());
      expect(deserialized.isExpired, isTrue);
    });
  });
}
