import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/domain/entities/jmap_metadata.dart';

extension type AccountId(String value) {}

class Account {
  final EmailAddress emailAddress;
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
}
