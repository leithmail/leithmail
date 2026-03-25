import 'package:flutter_test/flutter_test.dart';
import 'package:leithmail/domain/entities/credentials.dart';

void main() {
  group('isExpired', () {
    test('returns false when expiry is in the future', () {
      final credentials = CredentialsOidc.mock(
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(credentials.isExpired, isFalse);
    });

    test('returns true when expiry is in the past', () {
      final credentials = CredentialsOidc.mock(
        expiry: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(credentials.isExpired, isTrue);
    });

    test('returns true when expiry is exactly now', () {
      final expiry = DateTime.now().subtract(const Duration(milliseconds: 1));
      final credentials = CredentialsOidc.mock(expiry: expiry);
      expect(credentials.isExpired, isTrue);
    });

    test('returns false when expiry is null but access token is present', () {
      final credentials = CredentialsOidc.mock(expiry: null);
      expect(credentials.isExpired, isFalse);
    });

    test('returns true when access token is null regardless of expiry', () {
      final credentials = CredentialsOidc.mock(
        accessToken: null,
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(credentials.isExpired, isTrue);
    });

    test('returns true when both access token and expiry are null', () {
      final credentials = CredentialsOidc.mock(accessToken: null, expiry: null);
      expect(credentials.isExpired, isTrue);
    });
  });

  group('canBeRefreshed', () {
    test('returns true when refresh token is present', () {
      final credentials = CredentialsOidc.mock(refreshToken: 'refresh_token');
      expect(credentials.canBeRefreshed, isTrue);
    });

    test('returns false when refresh token is null', () {
      final credentials = CredentialsOidc.mock(refreshToken: null);
      expect(credentials.canBeRefreshed, isFalse);
    });
  });

  group('toAuthorizationHeader', () {
    test('returns bearer token', () {
      final credentials = CredentialsOidc.mock(accessToken: 'my_access_token');
      expect(credentials.toAuthorizationHeader(), 'Bearer my_access_token');
    });

    test('returns empty string when access token is null', () {
      final credentials = CredentialsOidc.mock(accessToken: null);
      expect(credentials.toAuthorizationHeader(), '');
    });

    test('header changes when access token changes', () {
      final a = CredentialsOidc.mock(accessToken: 'token_a');
      final b = CredentialsOidc.mock(accessToken: 'token_b');
      expect(a.toAuthorizationHeader(), isNot(b.toAuthorizationHeader()));
    });
  });

  group('copyWithTokens', () {
    test('updates access token, refresh token and expiry', () {
      final original = CredentialsOidc.mock().copyWithTokens(
        accessToken: null,
        refreshToken: null,
        expiry: null,
      );
      final expiry = DateTime.now().add(const Duration(hours: 1));
      final updated = original.copyWithTokens(
        accessToken: 'new_access_token',
        refreshToken: 'new_refresh_token',
        expiry: expiry,
      );

      expect(updated.accessToken, 'new_access_token');
      expect(updated.refreshToken, 'new_refresh_token');
      expect(updated.expiry, expiry);
    });

    test('preserves issuer and endpoint fields', () {
      final original = CredentialsOidc.mock();
      final updated = original.copyWithTokens(
        accessToken: 'new_token',
        refreshToken: null,
        expiry: null,
      );

      expect(updated.issuer, original.issuer);
      expect(updated.authorizationEndpoint, original.authorizationEndpoint);
      expect(updated.tokenEndpoint, original.tokenEndpoint);
      expect(updated.clientId, original.clientId);
    });

    test('can clear refresh token and expiry', () {
      final original = CredentialsOidc.mock();
      final updated = original.copyWithTokens(
        accessToken: 'new_token',
        refreshToken: null,
        expiry: null,
      );

      expect(updated.refreshToken, isNull);
      expect(updated.expiry, isNull);
    });
  });

  group('serialization', () {
    test('toJson and fromJson roundtrip', () {
      final credentials = CredentialsOidc.mock();
      final deserialized = CredentialsOidc.fromJson(credentials.toJson());
      expect(deserialized.accessToken, credentials.accessToken);
      expect(deserialized.refreshToken, credentials.refreshToken);
      expect(deserialized.expiry, credentials.expiry);
    });

    test('expiry is preserved after serialization', () {
      final expiry = DateTime(2026, 3, 19, 12, 0, 0);
      final credentials = CredentialsOidc.mock(expiry: expiry);
      final deserialized = CredentialsOidc.fromJson(credentials.toJson());
      expect(deserialized.expiry, expiry);
    });

    test('isExpired is preserved after serialization', () {
      final expired = CredentialsOidc.mock(
        expiry: DateTime.now().subtract(const Duration(hours: 1)),
      );
      final deserialized = CredentialsOidc.fromJson(expired.toJson());
      expect(deserialized.isExpired, isTrue);
    });

    test('null token fields roundtrip correctly', () {
      final credentials = CredentialsOidc.mock().copyWithTokens(
        accessToken: null,
        refreshToken: null,
        expiry: null,
      );
      final deserialized = CredentialsOidc.fromJson(credentials.toJson());
      expect(deserialized.accessToken, isNull);
      expect(deserialized.refreshToken, isNull);
      expect(deserialized.expiry, isNull);
    });

    test('uri fields are preserved after serialization', () {
      final credentials = CredentialsOidc.mock();
      final deserialized = CredentialsOidc.fromJson(credentials.toJson());
      expect(deserialized.issuer, credentials.issuer);
      expect(
        deserialized.authorizationEndpoint,
        credentials.authorizationEndpoint,
      );
      expect(deserialized.tokenEndpoint, credentials.tokenEndpoint);
    });
  });
}
