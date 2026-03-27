import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/jmap_session.dart';

part 'account.g.dart';

extension type AccountId(String value) {}

@JsonSerializable()
class Account {
  @JsonKey(fromJson: _accountIdFromJson, toJson: _accountIdToJson)
  final AccountId id;
  @JsonKey(fromJson: _credentialsFromJson, toJson: _credentialsToJson)
  final Credentials credentials;
  final JmapSession jmapSession;

  const Account({
    required this.id,
    required this.credentials,
    required this.jmapSession,
  });

  // coverage:ignore-start
  @override
  String toString() => '$runtimeType($id)';
  // coverage:ignore-end

  Account copyWith({Credentials? credentials, JmapSession? jmapSession}) {
    return Account(
      id: id,
      credentials: credentials ?? this.credentials,
      jmapSession: jmapSession ?? this.jmapSession,
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  factory Account.deserialize(String data) =>
      Account.fromJson(jsonDecode(data));

  String serialize() => jsonEncode(toJson());

  factory Account.mock({
    AccountId? id,
    Credentials? credentials,
    JmapSession? jmapSession,
  }) => Account(
    id: id ?? AccountId('test@example.com'),
    credentials: credentials ?? OidcCredentials.mock(),
    jmapSession: jmapSession ?? JmapSession.mock(),
  );
}

Credentials _credentialsFromJson(Map<String, dynamic> map) =>
    switch (map['type'] as String) {
      'oidc' => OidcCredentials.fromJson(map),
      _ => throw UnimplementedError('Unknown credentials type: ${map["type"]}'),
    };

Map<String, dynamic> _credentialsToJson(Credentials c) => switch (c) {
  OidcCredentials() => {'type': 'oidc', ...c.toJson()},
};

AccountId _accountIdFromJson(String v) => AccountId(v);
String _accountIdToJson(AccountId id) => id.value;
