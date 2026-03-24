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
      body:
          'Hi,\n\nSounds good — let\'s sync on Thursday afternoon. I\'ll book a room and send a calendar invite.\n\nFor the agenda: scope, timeline, and DRIs for each workstream. Let me know if you\'d like to add anything.\n\nCheers,\nBob',
      date: '10:42',
    ),
    MockEmail(
      id: '2',
      sender: 'Clara Wu',
      senderInitials: 'CW',
      subject: 'Design review feedback',
      preview: 'I\'ve attached my notes from yesterday\'s session...',
      body:
          'Hi,\n\nI\'ve attached my notes from yesterday\'s design review. Overall the direction looks solid.\n\nClara',
      date: '09:15',
    ),
    MockEmail(
      id: '3',
      sender: 'Newsletter',
      senderInitials: 'NL',
      subject: 'This week in open source',
      preview: 'Top stories: Dart 3.2 lands, Flutter 4 preview...',
      body:
          'This week\'s highlights:\n\n- Dart 3.2 released\n- Flutter 4 preview builds available\n- New JMAP client libraries gaining traction',
      date: 'Yesterday',
      isRead: true,
    ),
    MockEmail(
      id: '4',
      sender: 'Dan Eriksson',
      senderInitials: 'DE',
      subject: 'Server migration complete',
      preview: 'All services are running on the new infrastructure...',
      body:
          'All services are now running on the new infrastructure. Latency is down ~40ms on average.\n\nDan',
      date: 'Mon',
      isRead: true,
    ),
    MockEmail(
      id: '5',
      sender: 'Elena Morel',
      senderInitials: 'EM',
      subject: 'Invitation: Team offsite 2025',
      preview: 'Please RSVP by Friday — details inside...',
      body:
          'Hi everyone,\n\nWe\'re planning a team offsite for late Q2.\n\n📅 June 12–13\n📍 Prague, Czech Republic\n\nPlease RSVP by Friday.\n\nElena',
      date: 'Mon',
    ),
    MockEmail(
      id: '6',
      sender: 'GitHub',
      senderInitials: 'GH',
      subject: '[leithmail] PR #14 merged',
      preview: 'feat: add JMAP session autodiscovery...',
      body:
          'Pull request #14 was merged into main.\n\nfeat: add JMAP session autodiscovery',
      date: 'Sun',
      isRead: true,
    ),
    MockEmail(
      id: '7',
      sender: 'Petra Novák',
      senderInitials: 'PN',
      subject: 'Invoice #2025-041',
      preview: 'Please find attached the invoice for March services...',
      body:
          'Hi,\n\nPlease find attached the invoice for March services. Payment due within 14 days.\n\nThanks,\nPetra',
      date: 'Sun',
      isRead: true,
    ),
    MockEmail(
      id: '8',
      sender: 'Tomáš Blaha',
      senderInitials: 'TB',
      subject: 'Stalwart config question',
      preview: 'Hey, do you know if Stalwart supports per-domain DKIM...',
      body:
          'Hey,\n\nDo you know if Stalwart supports per-domain DKIM key rotation? I\'ve been looking through the docs but can\'t find a clear answer.\n\nTomáš',
      date: 'Sun',
    ),
    MockEmail(
      id: '9',
      sender: 'Lena Fischer',
      senderInitials: 'LF',
      subject: 'Re: OIDC discovery edge cases',
      preview: 'Right, WebFinger fallback is tricky when the domain...',
      body:
          'Right, WebFinger fallback is tricky when the domain doesn\'t host a WebFinger endpoint at all. I\'d suggest treating a 404 as a clean skip rather than an error.\n\nLena',
      date: 'Sat',
      isRead: true,
    ),
    MockEmail(
      id: '10',
      sender: 'GitHub',
      senderInitials: 'GH',
      subject: '[leithmail] Issue #22 opened',
      preview: 'bug: email list doesn\'t scroll on Firefox...',
      body:
          'Issue #22 was opened.\n\nbug: email list doesn\'t scroll on Firefox\n\nReproducible on Firefox 124, works fine on Chrome and Safari.',
      date: 'Sat',
    ),
    MockEmail(
      id: '11',
      sender: 'Martin Dvořák',
      senderInitials: 'MD',
      subject: 'Hosting plan upgrade',
      preview: 'We\'d like to move to the business tier — can you send...',
      body:
          'Hi,\n\nWe\'d like to upgrade to the business tier starting next month. Could you send over the updated pricing and what\'s included?\n\nThanks,\nMartin',
      date: 'Sat',
    ),
    MockEmail(
      id: '12',
      sender: 'Zitadel',
      senderInitials: 'ZI',
      subject: 'Your organisation: login policy updated',
      preview: 'A login policy change was applied to your organisation...',
      body:
          'A login policy change was applied to your Zitadel organisation.\n\nIf you did not make this change, please review your audit log immediately.',
      date: 'Fri',
      isRead: true,
    ),
    MockEmail(
      id: '13',
      sender: 'Anna Kowalski',
      senderInitials: 'AK',
      subject: 'Flutter Web performance question',
      preview: 'Have you tried the CanvasKit renderer vs HTML renderer...',
      body:
          'Hi,\n\nHave you compared CanvasKit vs HTML renderer for your use case? We saw a significant difference in text rendering quality on CanvasKit, but initial load time went up.\n\nAnna',
      date: 'Fri',
    ),
    MockEmail(
      id: '14',
      sender: 'Uptime Kuma',
      senderInitials: 'UK',
      subject: '[RESOLVED] mail.example.com is back up',
      preview: 'Your monitor mail.example.com is UP again after 3 min...',
      body:
          '[RESOLVED] mail.example.com is UP\n\nDowntime: 3 minutes\nIncident started: 2025-03-21 02:14 UTC\nResolved: 2025-03-21 02:17 UTC',
      date: 'Fri',
      isRead: true,
    ),
    MockEmail(
      id: '15',
      sender: 'Jakub Hora',
      senderInitials: 'JH',
      subject: 'Re: shared mailbox permissions',
      preview:
          'I think the issue is the ACL entry is missing the \'e\' flag...',
      body:
          'I think the issue is the ACL entry is missing the \'e\' flag for expunge. Try:\n\ncyradm> setacl INBOX.shared user@example.com lrswipekxte\n\nJakub',
      date: 'Thu',
      isRead: true,
    ),
    MockEmail(
      id: '16',
      sender: 'Sophie Bernard',
      senderInitials: 'SB',
      subject: 'Contract renewal reminder',
      preview: 'Your current contract expires on April 30th...',
      body:
          'Hi,\n\nThis is a reminder that your current contract expires on April 30th. Please let us know if you\'d like to renew or discuss updated terms.\n\nSophie',
      date: 'Thu',
    ),
    MockEmail(
      id: '17',
      sender: 'Netdata',
      senderInitials: 'ND',
      subject: 'Alert: high memory usage on zahon',
      preview: 'Memory usage exceeded 85% threshold for 10 minutes...',
      body:
          'Alert: Memory usage on zahon exceeded 85% threshold.\n\nDuration: 10 minutes\nPeak: 91%\nTime: 2025-03-20 14:33 UTC\n\nThis alert has since cleared.',
      date: 'Thu',
      isRead: true,
    ),
    MockEmail(
      id: '18',
      sender: 'Radek Šimánek',
      senderInitials: 'RS',
      subject: 'Can we schedule a demo?',
      preview: 'We\'re evaluating self-hosted email solutions and your...',
      body:
          'Hi,\n\nWe\'re evaluating self-hosted email solutions for our team of 30. I came across your hosting service — would it be possible to schedule a short demo this week?\n\nRadek',
      date: 'Wed',
    ),
    MockEmail(
      id: '19',
      sender: 'GitHub',
      senderInitials: 'GH',
      subject: '[leithmail] PR #18: fix signal disposal',
      preview: 'ondra opened a pull request...',
      body:
          'Pull request #18 was opened.\n\nfix: dispose signals in ControllerBase.onDispose\n\nPreviously signals were not disposed on controller teardown, causing memory leaks in long-running sessions.',
      date: 'Wed',
      isRead: true,
    ),
    MockEmail(
      id: '20',
      sender: 'Michaela Černá',
      senderInitials: 'MC',
      subject: 'Re: DNS SRV record setup',
      preview: 'Yes, the _jmap._tcp record should point to port 443...',
      body:
          'Yes, the _jmap._tcp SRV record should point to port 443 with your JMAP server hostname. Something like:\n\n_jmap._tcp.example.com. 86400 IN SRV 0 1 443 jmap.example.com.\n\nMichaela',
      date: 'Wed',
      isRead: true,
    ),
    MockEmail(
      id: '21',
      sender: 'Let\'s Encrypt',
      senderInitials: 'LE',
      subject: 'Certificate expiry notice',
      preview: 'Your certificate for mail.example.com expires in 20 days...',
      body:
          'Your certificate for mail.example.com will expire in 20 days.\n\nPlease renew it before expiry to avoid service interruption.',
      date: 'Tue',
      isRead: true,
    ),
    MockEmail(
      id: '22',
      sender: 'Filip Král',
      senderInitials: 'FK',
      subject: 'Feedback on the beta',
      preview: 'Tested it with our Stalwart instance — works great...',
      body:
          'Hi,\n\nTested Leithmail against our Stalwart instance. Works great overall. One issue: the email list doesn\'t update after moving a message to a different mailbox without a manual refresh.\n\nFilip',
      date: 'Tue',
    ),
    MockEmail(
      id: '23',
      sender: 'Ondřej Pospíšil',
      senderInitials: 'OP',
      subject: 'Re: push notification architecture',
      preview: 'UnifiedPush makes sense for Android, but for iOS you\'ll...',
      body:
          'UnifiedPush makes sense for Android, but for iOS you\'ll need your own APNs proxy regardless. The Element/Matrix model is the right reference — they run a minimal proxy that only forwards wake-up pings, no content.\n\nOndřej',
      date: 'Tue',
      isRead: true,
    ),
    MockEmail(
      id: '24',
      sender: 'Věra Horáčková',
      senderInitials: 'VH',
      subject: 'New tenant onboarding request',
      preview: 'We\'d like to set up email for our small team of 8...',
      body:
          'Hi,\n\nWe\'d like to set up email hosting for our team of 8. We\'re a small accounting firm based in Brno. Could you let us know what\'s needed to get started?\n\nVěra',
      date: 'Mon',
    ),
    MockEmail(
      id: '25',
      sender: 'Stack Overflow',
      senderInitials: 'SO',
      subject: 'New answer on your question',
      preview: 'Someone answered: "Flutter web and browser history..."',
      body:
          'Your question "Flutter web: disable browser history integration with go_router" received a new answer.\n\nView it at stackoverflow.com',
      date: 'Mon',
      isRead: true,
    ),
    MockEmail(
      id: '26',
      sender: 'Lucie Marková',
      senderInitials: 'LM',
      subject: 'Re: SCIM provisioning with Zitadel',
      preview: 'The SCIM endpoint is at /scim/v2 — you\'ll need a machine...',
      body:
          'The SCIM endpoint is at /scim/v2. You\'ll need a machine user with the org:write permission and a PAT for the Authorization header. Works well for automating user provisioning.\n\nLucie',
      date: 'Mon',
      isRead: true,
    ),
    MockEmail(
      id: '27',
      sender: 'Pavel Novotný',
      senderInitials: 'PN',
      subject: 'Meeting notes — infrastructure review',
      preview: 'Attached are the notes from Tuesday\'s infra review...',
      body:
          'Hi,\n\nAttached are the notes from Tuesday\'s infrastructure review. Key decisions:\n\n- Keep Stalwart, evaluate clustering in Q3\n- Move monitoring to dedicated VM\n- Evaluate Netdata Cloud vs self-hosted\n\nPavel',
      date: '21 Mar',
      isRead: true,
    ),
    MockEmail(
      id: '28',
      sender: 'GitHub',
      senderInitials: 'GH',
      subject: '[leithmail] Security advisory',
      preview: 'A dependency has a known vulnerability — details inside...',
      body:
          'Dependabot has detected a vulnerability in one of your dependencies.\n\nPackage: http\nSeverity: moderate\nRecommended action: upgrade to 1.2.2',
      date: '20 Mar',
    ),
    MockEmail(
      id: '29',
      sender: 'Karolína Šťastná',
      senderInitials: 'KS',
      subject: 'Question about data residency',
      preview: 'We\'re based in the EU — where are the servers located?...',
      body:
          'Hi,\n\nWe\'re a Czech company and need to confirm data residency before signing up. Where are your servers located? Do you offer a DPA?\n\nKarolína',
      date: '20 Mar',
    ),
    MockEmail(
      id: '30',
      sender: 'Marek Fišer',
      senderInitials: 'MF',
      subject: 'Re: custom domain setup',
      preview: 'Add the MX record pointing to mail.example.com with...',
      body:
          'Add the MX record pointing to mail.example.com with priority 10. Also add SPF and DKIM — Stalwart generates the DKIM DNS record for you under Settings > DKIM.\n\nMarek',
      date: '19 Mar',
      isRead: true,
    ),
    MockEmail(
      id: '31',
      sender: 'Tereza Blažková',
      senderInitials: 'TB',
      subject: 'UI feedback — mobile view',
      preview: 'On mobile the sidebar overlaps the email list on narrow...',
      body:
          'Hi,\n\nOn mobile the sidebar overlaps the email list on narrow screens (tested on iPhone 14). The drawer doesn\'t close after selecting a mailbox either.\n\nTereza',
      date: '19 Mar',
    ),
    MockEmail(
      id: '32',
      sender: 'Newsletter',
      senderInitials: 'NL',
      subject: 'JMAP ecosystem update — March 2025',
      preview: 'Fastmail publishes JMAP extensions draft, Cyrus 3.10...',
      body:
          'This month in JMAP:\n\n- Fastmail published a draft for JMAP Blob extensions\n- Cyrus IMAP 3.10 ships improved JMAP performance\n- Apache James 3.9 adds JMAP Push support',
      date: '18 Mar',
      isRead: true,
    ),
    MockEmail(
      id: '33',
      sender: 'Dominik Procházka',
      senderInitials: 'DP',
      subject: 'Re: Dart sealed classes',
      preview: 'Yes, sealed classes with exhaustive switch are perfect...',
      body:
          'Yes, sealed classes with exhaustive switch are exactly the right tool here. Much better than abstract classes + manual type checks. Worth the Dart 3 upgrade if you haven\'t already.\n\nDominík',
      date: '18 Mar',
      isRead: true,
    ),
    MockEmail(
      id: '34',
      sender: 'Barbora Krejčí',
      senderInitials: 'BK',
      subject: 'Invoice dispute',
      preview: 'The invoice #2025-038 appears to charge for a service...',
      body:
          'Hi,\n\nInvoice #2025-038 appears to include a charge for a service we cancelled in February. Could you please review and issue a corrected invoice?\n\nBarbora',
      date: '17 Mar',
    ),
    MockEmail(
      id: '35',
      sender: 'Uptime Kuma',
      senderInitials: 'UK',
      subject: '[DOWN] smtp.example.com is unreachable',
      preview: 'Your monitor smtp.example.com is DOWN...',
      body:
          '[DOWN] smtp.example.com is unreachable\n\nTime: 2025-03-17 08:02 UTC\nLast successful check: 2025-03-17 07:57 UTC',
      date: '17 Mar',
      isRead: true,
    ),
    MockEmail(
      id: '36',
      sender: 'Jiří Veselý',
      senderInitials: 'JV',
      subject: 'Open source contribution interest',
      preview: 'I\'d love to contribute to Leithmail — are there any...',
      body:
          'Hi,\n\nI\'ve been following the Leithmail project and would love to contribute. Are there any good first issues tagged? I\'m comfortable with Flutter and have some JMAP experience.\n\nJiří',
      date: '16 Mar',
    ),
    MockEmail(
      id: '37',
      sender: 'Eliška Houšková',
      senderInitials: 'EH',
      subject: 'Re: tenant isolation in Stalwart',
      preview: 'Each tenant gets its own virtual domain — mailboxes are...',
      body:
          'Each tenant gets its own virtual domain. Mailboxes are isolated by default; the only shared resource is the SMTP listener. You can further restrict with per-domain rate limits.\n\nEliška',
      date: '15 Mar',
      isRead: true,
    ),
    MockEmail(
      id: '38',
      sender: 'GitHub',
      senderInitials: 'GH',
      subject: '[leithmail] PR #21 merged',
      preview: 'refactor: replace GetX controllers with signals...',
      body:
          'Pull request #21 was merged into main.\n\nrefactor: replace GetX controllers with signals\n\nRemoves all GetX dependencies from presentation layer. Controllers now expose Signal<T> and Computed<T>.',
      date: '14 Mar',
      isRead: true,
    ),
    MockEmail(
      id: '39',
      sender: 'Vojtěch Kratochvíl',
      senderInitials: 'VK',
      subject: 'Webinar invite: self-hosted email in 2025',
      preview: 'Join us for a live session on running your own mail...',
      body:
          'Hi,\n\nYou\'re invited to our upcoming webinar: "Self-hosted email in 2025 — Stalwart, JMAP, and beyond."\n\n📅 April 3rd, 18:00 CET\n🔗 Register at example.com/webinar\n\nVojtěch',
      date: '14 Mar',
      isRead: true,
    ),
    MockEmail(
      id: '40',
      sender: 'Simona Procházková',
      senderInitials: 'SP',
      subject: 'Re: annual pricing review',
      preview: 'Happy with the current plan — no changes needed from our...',
      body:
          'Hi,\n\nHappy with the current plan, no changes needed from our side. Thanks for checking in.\n\nSimona',
      date: '13 Mar',
      isRead: true,
    ),
  ];

  @override
  Future<List<MockEmail>> getEmails(String mailboxId) async => _emails;
}
