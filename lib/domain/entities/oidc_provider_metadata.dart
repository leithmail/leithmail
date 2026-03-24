class OidcProviderMetadata {
  final Uri issuer;
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final String? clientId;

  OidcProviderMetadata({
    required this.issuer,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    this.clientId,
  });
}
