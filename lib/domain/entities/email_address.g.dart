// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailAddress _$EmailAddressFromJson(Map<String, dynamic> json) => EmailAddress(
  local: json['local'] as String,
  domain: json['domain'] as String,
);

Map<String, dynamic> _$EmailAddressToJson(EmailAddress instance) =>
    <String, dynamic>{'local': instance.local, 'domain': instance.domain};
