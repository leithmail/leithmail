import 'package:json_annotation/json_annotation.dart';

part 'email_address.g.dart';

@JsonSerializable()
class EmailAddress {
  final String local;
  final String domain;

  const EmailAddress({required this.local, required this.domain});

  factory EmailAddress.parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Email address is empty');
    }
    final parts = trimmed.split('@');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      throw FormatException('Invalid email address: $raw');
    }
    return EmailAddress(local: parts[0], domain: parts[1]);
  }

  String get value => toString();

  @override
  bool operator ==(Object other) =>
      other is EmailAddress && other.local == local && other.domain == domain;

  @override
  int get hashCode => Object.hash(local, domain);

  @override
  String toString() => '$local@$domain';

  factory EmailAddress.fromJson(Map<String, dynamic> json) =>
      _$EmailAddressFromJson(json);

  Map<String, dynamic> toJson() => _$EmailAddressToJson(this);
}
