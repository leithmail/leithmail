// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialsOidc _$CredentialsOidcFromJson(Map<String, dynamic> json) =>
    CredentialsOidc(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiry: DateTime.parse(json['expiry'] as String),
      tokenEndpoint: Uri.parse(json['tokenEndpoint'] as String),
      clientId: json['clientId'] as String,
    );

Map<String, dynamic> _$CredentialsOidcToJson(CredentialsOidc instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiry': instance.expiry.toIso8601String(),
      'tokenEndpoint': instance.tokenEndpoint.toString(),
      'clientId': instance.clientId,
    };
