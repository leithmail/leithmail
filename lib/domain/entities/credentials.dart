import 'package:json_annotation/json_annotation.dart';

part 'credentials.g.dart';

sealed class Credentials {
  String toAuthorizationHeader();
  bool get isExpired;
  bool get canBeRefreshed;
}

@JsonSerializable()
class OidcCredentials extends Credentials {
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiry;

  final Uri issuer;
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final String clientId;

  OidcCredentials({
    this.accessToken,
    this.refreshToken,
    this.expiry,
    required this.issuer,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.clientId,
  });

  @override
  bool get isExpired {
    if (accessToken == null) {
      return true;
    }
    final exp = expiry;
    return exp != null && DateTime.now().isAfter(exp);
  }

  @override
  bool get canBeRefreshed => refreshToken != null;

  @override
  String toAuthorizationHeader() =>
      accessToken != null ? 'Bearer $accessToken' : '';

  OidcCredentials copyWithTokens({
    required String? accessToken,
    required String? refreshToken,
    required DateTime? expiry,
  }) => OidcCredentials(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiry: expiry,
    issuer: issuer,
    authorizationEndpoint: authorizationEndpoint,
    tokenEndpoint: tokenEndpoint,
    clientId: clientId,
  );

  factory OidcCredentials.fromJson(Map<String, dynamic> json) =>
      _$OidcCredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$OidcCredentialsToJson(this);

  factory OidcCredentials.mock({
    String? accessToken = 'mock_access_token',
    String? refreshToken = 'mock_refresh_token',
    DateTime? expiry,
    Uri? issuer,
    Uri? authorizationEndpoint,
    Uri? tokenEndpoint,
    String clientId = 'mock_client_id',
  }) => OidcCredentials(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiry: expiry ?? DateTime.now().add(const Duration(hours: 1)),
    issuer: issuer ?? Uri.parse('https://mock.issuer.example.com'),
    authorizationEndpoint:
        authorizationEndpoint ??
        Uri.parse('https://mock.issuer.example.com/authorize'),
    tokenEndpoint:
        tokenEndpoint ?? Uri.parse('https://mock.issuer.example.com/token'),
    clientId: clientId,
  );
}
