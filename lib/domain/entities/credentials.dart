abstract class Credentials {
  String toAuthorizationHeader();
  bool get isExpired;
}
