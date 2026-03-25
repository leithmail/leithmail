import 'package:leithmail/domain/entities/account.dart';

sealed class AppFailure {
  const AppFailure();
}

/// The requested resource was not found.
class NotFoundFailure extends AppFailure {
  const NotFoundFailure([this.message]);
  final String? message;

  @override
  String toString() => '$runtimeType(${message ?? ''})';
}

/// Authentication failed or credentials have expired.
class AuthFailure extends AppFailure {
  const AuthFailure([this.message]);
  final String? message;

  @override
  String toString() => '$runtimeType(${message ?? ''})';
}

/// A network error occurred (no connectivity, timeout, etc.).
class NetworkFailure extends AppFailure {
  const NetworkFailure([this.message]);
  final String? message;

  @override
  String toString() => '$runtimeType(${message ?? ''})';
}

/// A local storage read/write error occurred.
class StorageFailure extends AppFailure {
  const StorageFailure([this.message]);
  final String? message;

  @override
  String toString() => '$runtimeType(${message ?? ''})';
}

/// The JMAP server returned an error response.
class JmapFailure extends AppFailure {
  const JmapFailure([this.message]);
  final String? message;

  @override
  String toString() => '$runtimeType(${message ?? ''})';
}

/// The credentials for the given account have expired and the user must re-authenticate.
/// The controller should trigger the OIDC refresh or redirect to login.
class CredentialsExpiredFailure extends AppFailure {
  const CredentialsExpiredFailure({this.accountId});
  final AccountId? accountId;

  @override
  String toString() => '$runtimeType($accountId)';
}

/// Feature is not implemented
class NotImplementedFailure extends AppFailure {
  const NotImplementedFailure([this.message]);
  final String? message;

  @override
  String toString() => '$runtimeType(${message ?? ''})';
}

/// An unexpected exception that escaped the use case.
/// Produced automatically by [UsecaseBase] — never construct manually.
class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(this.error, this.stackTrace);
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() => '$runtimeType($error)';
}
