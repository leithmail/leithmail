import 'package:leithmail/domain/entities/credentials.dart';

class CredentialsOidc extends Credentials {
  final String accessToken;
  final String refreshToken;
  final DateTime expiry;

  CredentialsOidc({
    required this.accessToken,
    required this.refreshToken,
    required this.expiry,
  });

  @override
  bool get isExpired => DateTime.now().isAfter(expiry);

  @override
  String toAuthorizationHeader() => 'Bearer $accessToken';
}
