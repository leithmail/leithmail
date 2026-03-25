// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  emailAddress: EmailAddress.fromJson(
    json['emailAddress'] as Map<String, dynamic>,
  ),
  credentials: _credentialsFromJson(
    json['credentials'] as Map<String, dynamic>,
  ),
  jmapSession: JmapSession.fromJson(
    json['jmapSession'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'emailAddress': instance.emailAddress,
  'credentials': _credentialsToJson(instance.credentials),
  'jmapSession': instance.jmapSession,
};
