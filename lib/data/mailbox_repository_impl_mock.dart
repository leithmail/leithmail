import 'package:leithmail/domain/entities/mock_mailbox.dart';
import 'package:leithmail/domain/repositories/mailbox_repository.dart';

class MailboxRepositoryImplMock implements MailboxRepository {
  @override
  Future<List<MockMailbox>> getMailboxes() async => const [
    MockMailbox(
      id: 'inbox',
      name: 'Inbox',
      role: MailboxRole.inbox,
      unreadCount: 3,
    ),
    MockMailbox(id: 'starred', name: 'Starred', role: MailboxRole.starred),
    MockMailbox(id: 'sent', name: 'Sent', role: MailboxRole.sent),
    MockMailbox(
      id: 'drafts',
      name: 'Drafts',
      role: MailboxRole.drafts,
      unreadCount: 2,
    ),
    MockMailbox(id: 'trash', name: 'Trash', role: MailboxRole.trash),
  ];
}
