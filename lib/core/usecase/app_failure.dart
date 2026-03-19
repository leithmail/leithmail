sealed class AppFailure {
  const AppFailure();
}

/// The requested resource was not found.
class NotFoundFailure extends AppFailure {
  const NotFoundFailure([this.message]);
  final String? message;

  @override
  String toString() => 'NotFoundFailure(${message ?? ''})';
}

/// Authentication failed or credentials have expired.
class AuthFailure extends AppFailure {
  const AuthFailure([this.message]);
  final String? message;

  @override
  String toString() => 'AuthFailure(${message ?? ''})';
}

/// A network error occurred (no connectivity, timeout, etc.).
class NetworkFailure extends AppFailure {
  const NetworkFailure([this.message]);
  final String? message;

  @override
  String toString() => 'NetworkFailure(${message ?? ''})';
}

/// A local storage read/write error occurred.
class StorageFailure extends AppFailure {
  const StorageFailure([this.message]);
  final String? message;

  @override
  String toString() => 'StorageFailure(${message ?? ''})';
}

/// The JMAP server returned an error response.
class ServerFailure extends AppFailure {
  const ServerFailure([this.message]);
  final String? message;

  @override
  String toString() => 'ServerFailure(${message ?? ''})';
}

/// An unexpected exception that escaped the use case.
/// Produced automatically by [UsecaseBase] — never construct manually.
class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(this.error, this.stackTrace);
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() => 'UnexpectedFailure($error)';
}
