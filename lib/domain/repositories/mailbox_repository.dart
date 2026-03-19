import 'package:leithmail/domain/entities/mock_mailbox.dart';

abstract interface class MailboxRepository {
  Future<List<MockMailbox>> getMailboxes();
}
