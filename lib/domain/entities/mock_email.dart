class MockEmail {
  const MockEmail({
    required this.id,
    required this.sender,
    required this.senderInitials,
    required this.subject,
    required this.preview,
    required this.body,
    required this.date,
    this.isRead = false,
  });

  final String id;
  final String sender;
  final String senderInitials;
  final String subject;
  final String preview;
  final String body;
  final String date;
  final bool isRead;

  @override
  String toString() => '$runtimeType($id)';
}
