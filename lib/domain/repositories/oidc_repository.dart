import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/credentials.dart';

abstract class OidcRepository {
  Future<OidcCredentials> discoverProvider(String domain);
  Future<OidcCredentials> refresh(OidcCredentials credentials);
  Future<OidcCredentials> authenticate(
    OidcCredentials credentials, {
    String? loginHint,
  });
  Future<Uri> getAuthUrl({
    required AccountId accountId,
    required OidcCredentials credentials,
    required Uri jmapSessionEndpoint,
    String? loginHint,
  });
  Future<
    ({
      AccountId accountId,
      Uri jmapSessionEndpoint,
      OidcCredentials credentials,
    })
  >
  finishAuthFlow({required String state, required String code});
}

class OidcDiscoveryException implements Exception {
  final String message;
  const OidcDiscoveryException(this.message);

  @override
  String toString() => '$runtimeType($message)';
}

class OidcAuthException implements Exception {
  final String message;
  const OidcAuthException(this.message);

  @override
  String toString() => '$runtimeType($message)';
}
