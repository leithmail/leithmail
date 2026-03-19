import 'package:leithmail/domain/entities/mock_email.dart';

abstract interface class EmailRepository {
  Future<List<MockEmail>> getEmails(String mailboxId);
}
