import 'package:json_annotation/json_annotation.dart';

part 'credentials.g.dart';

sealed class Credentials {
  String toAuthorizationHeader();
  bool get isExpired;
  bool get canBeRefreshed;
}

@JsonSerializable()
class CredentialsOidc extends Credentials {
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiry;

  final Uri issuer;
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final String clientId;

  CredentialsOidc({
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

  CredentialsOidc copyWithTokens({
    required String? accessToken,
    required String? refreshToken,
    required DateTime? expiry,
  }) => CredentialsOidc(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiry: expiry,
    issuer: issuer,
    authorizationEndpoint: authorizationEndpoint,
    tokenEndpoint: tokenEndpoint,
    clientId: clientId,
  );

  factory CredentialsOidc.fromJson(Map<String, dynamic> json) =>
      _$CredentialsOidcFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialsOidcToJson(this);

  factory CredentialsOidc.mock({
    String? accessToken = 'mock_access_token',
    String? refreshToken = 'mock_refresh_token',
    DateTime? expiry,
    Uri? issuer,
    Uri? authorizationEndpoint,
    Uri? tokenEndpoint,
    String clientId = 'mock_client_id',
  }) => CredentialsOidc(
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
