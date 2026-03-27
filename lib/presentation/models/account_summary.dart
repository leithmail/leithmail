import 'package:leithmail/domain/entities/account.dart';

class AccountSummary {
  const AccountSummary({required this.id, required this.unreadCount});

  final AccountId id;
  final int unreadCount;
}
