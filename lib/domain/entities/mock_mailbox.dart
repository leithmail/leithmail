import 'package:flutter/material.dart';

enum MailboxRole { inbox, starred, sent, drafts, trash }

class MockMailbox {
  const MockMailbox({
    required this.id,
    required this.name,
    required this.role,
    this.unreadCount = 0,
  });

  final String id;
  final String name;
  final MailboxRole role;
  final int unreadCount;

  @override
  String toString() => '$runtimeType($name)';

  IconData get icon => switch (role) {
    MailboxRole.inbox => Icons.inbox_outlined,
    MailboxRole.starred => Icons.star_outline,
    MailboxRole.sent => Icons.send_outlined,
    MailboxRole.drafts => Icons.edit_outlined,
    MailboxRole.trash => Icons.delete_outline,
  };
}
