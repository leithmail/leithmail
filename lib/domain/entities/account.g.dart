// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  id: _accountIdFromJson(json['id'] as String),
  credentials: _credentialsFromJson(
    json['credentials'] as Map<String, dynamic>,
  ),
  jmapSession: JmapSession.fromJson(
    json['jmapSession'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'id': _accountIdToJson(instance.id),
  'credentials': _credentialsToJson(instance.credentials),
  'jmapSession': instance.jmapSession,
};
