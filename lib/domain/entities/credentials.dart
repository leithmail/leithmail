import 'package:json_annotation/json_annotation.dart';

part 'credentials.g.dart';

sealed class Credentials {
  String toAuthorizationHeader();
  bool get isExpired;
}

@JsonSerializable()
class CredentialsOidc extends Credentials {
  final String accessToken;
  final String refreshToken;
  final DateTime expiry;
  final Uri tokenEndpoint;
  final String clientId;

  CredentialsOidc({
    required this.accessToken,
    required this.refreshToken,
    required this.expiry,
    required this.tokenEndpoint,
    required this.clientId,
  });

  @override
  bool get isExpired => DateTime.now().isAfter(expiry);

  @override
  String toAuthorizationHeader() => 'Bearer $accessToken';

  factory CredentialsOidc.fromJson(Map<String, dynamic> json) =>
      _$CredentialsOidcFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialsOidcToJson(this);
}
