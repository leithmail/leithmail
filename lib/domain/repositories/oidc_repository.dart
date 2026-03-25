import 'package:leithmail/domain/entities/credentials.dart';

abstract class OidcRepository {
  Future<OidcCredentials> discoverProvider(String domain);
  Future<OidcCredentials> authenticate(
    OidcCredentials credentials, {
    String? loginHint,
  });
  Future<OidcCredentials> refresh(OidcCredentials credentials);
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
