import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/domain/entities/oidc_provider_metadata.dart';

abstract class OidcRepository {
  Future<OidcProviderMetadata?> discoverProvider(EmailAddress email);
  Future<CredentialsOidc> authenticate(
    OidcProviderMetadata metadata,
    EmailAddress email,
  );
  Future<CredentialsOidc> refresh(CredentialsOidc credentials);
}

class OidcDiscoveryException implements Exception {
  final String message;
  const OidcDiscoveryException(this.message);

  @override
  String toString() => 'OidcDiscoveryException: $message';
}

class OidcAuthException implements Exception {
  final String message;
  const OidcAuthException(this.message);

  @override
  String toString() => 'OidcAuthException: $message';
}
