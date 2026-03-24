import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/domain/entities/jmap_metadata.dart';

part 'account.g.dart';

extension type AccountId(String value) {}

@JsonSerializable()
class Account {
  final EmailAddress emailAddress;

  @JsonKey(fromJson: _credentialsFromJson, toJson: _credentialsToJson)
  final Credentials credentials;
  final JmapMetadata jmap;

  const Account({
    required this.emailAddress,
    required this.credentials,
    required this.jmap,
  });

  AccountId get id => AccountId(emailAddress.toString());

  Account copyWith({Credentials? credentials, JmapMetadata? jmap}) {
    return Account(
      emailAddress: emailAddress,
      credentials: credentials ?? this.credentials,
      jmap: jmap ?? this.jmap,
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  factory Account.deserialize(String data) =>
      Account.fromJson(jsonDecode(data));

  String serialize() => jsonEncode(toJson());

  factory Account.mock({
    String email = 'test@example.com',
    Credentials? credentials,
    JmapMetadata? jmap,
  }) => Account(
    emailAddress: EmailAddress.parse(email),
    credentials:
        credentials ??
        CredentialsOidc(
          tokenEndpoint: Uri(),
          accessToken: 'token',
          refreshToken: 'refresh',
          expiry: DateTime(2026),
          clientId: 'leithmail_mock',
        ),
    jmap:
        jmap ??
        JmapMetadata(
          apiUrl: Uri.parse('https://jmap.example.com'),
          downloadUrl: Uri.parse('https://jmap.example.com/download'),
          uploadUrl: Uri.parse('https://jmap.example.com/upload'),
          eventSourceUrl: Uri.parse('https://jmap.example.com/events'),
        ),
  );
}

Credentials _credentialsFromJson(Map<String, dynamic> map) =>
    switch (map['type'] as String) {
      'oidc' => CredentialsOidc.fromJson(map),
      _ => throw UnimplementedError('Unknown credentials type: ${map["type"]}'),
    };

Map<String, dynamic> _credentialsToJson(Credentials c) => switch (c) {
  CredentialsOidc() => {'type': 'oidc', ...c.toJson()},
};
