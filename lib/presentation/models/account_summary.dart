import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/email_address.dart';

class AccountSummary {
  const AccountSummary({
    required this.id,
    required this.emailAddress,
    required this.unreadCount,
  });

  final AccountId id;
  final EmailAddress emailAddress;
  final int unreadCount;
}
