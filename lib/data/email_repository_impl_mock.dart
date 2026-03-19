import 'package:leithmail/domain/entities/mock_email.dart';
import 'package:leithmail/domain/repositories/email_repository.dart';

class EmailRepositoryImplMock implements EmailRepository {
  static const _emails = [
    MockEmail(
      id: '1',
      sender: 'Bob Martin',
      senderInitials: 'BM',
      subject: 'Re: Q3 project kickoff',
      preview: 'Sounds good, let\'s sync on Thursday afternoon...',
      body: 'Hi,\n\nSounds good — let\'s sync on Thursday afternoon. I\'ll book a room and send a calendar invite.\n\nFor the agenda: scope, timeline, and DRIs for each workstream. Let me know if you\'d like to add anything.\n\nCheers,\nBob',
      date: '10:42',
    ),
    MockEmail(
      id: '2',
      sender: 'Clara Wu',
      senderInitials: 'CW',
      subject: 'Design review feedback',
      preview: 'I\'ve attached my notes from yesterday\'s session...',
      body: 'Hi,\n\nI\'ve attached my notes from yesterday\'s design review. Overall the direction looks solid.\n\nClara',
      date: '09:15',
    ),
    MockEmail(
      id: '3',
      sender: 'Newsletter',
      senderInitials: 'NL',
      subject: 'This week in open source',
      preview: 'Top stories: Dart 3.2 lands, Flutter 4 preview...',
      body: 'This week\'s highlights:\n\n- Dart 3.2 released\n- Flutter 4 preview builds available\n- New JMAP client libraries gaining traction',
      date: 'Yesterday',
      isRead: true,
    ),
    MockEmail(
      id: '4',
      sender: 'Dan Eriksson',
      senderInitials: 'DE',
      subject: 'Server migration complete',
      preview: 'All services are running on the new infrastructure...',
      body: 'All services are now running on the new infrastructure. Latency is down ~40ms on average.\n\nDan',
      date: 'Mon',
      isRead: true,
    ),
    MockEmail(
      id: '5',
      sender: 'Elena Morel',
      senderInitials: 'EM',
      subject: 'Invitation: Team offsite 2025',
      preview: 'Please RSVP by Friday — details inside...',
      body: 'Hi everyone,\n\nWe\'re planning a team offsite for late Q2.\n\n📅 June 12–13\n📍 Prague, Czech Republic\n\nPlease RSVP by Friday.\n\nElena',
      date: 'Mon',
    ),
    MockEmail(
      id: '6',
      sender: 'GitHub',
      senderInitials: 'GH',
      subject: '[leithmail] PR #14 merged',
      preview: 'feat: add JMAP session autodiscovery...',
      body: 'Pull request #14 was merged into main.\n\nfeat: add JMAP session autodiscovery',
      date: 'Sun',
      isRead: true,
    ),
  ];

  @override
  Future<List<MockEmail>> getEmails(String mailboxId) async => _emails;
}
