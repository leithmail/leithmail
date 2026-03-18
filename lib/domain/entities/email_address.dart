class EmailAddress {
  final String local;
  final String domain;

  const EmailAddress({required this.local, required this.domain});

  factory EmailAddress.parse(String raw) {
    final parts = raw.split('@');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      throw FormatException('Invalid email address: $raw');
    }
    return EmailAddress(local: parts[0], domain: parts[1]);
  }

  @override
  bool operator ==(Object other) =>
      other is EmailAddress && other.local == local && other.domain == domain;

  @override
  int get hashCode => Object.hash(local, domain);

  @override
  String toString() => '$local@$domain';
}
