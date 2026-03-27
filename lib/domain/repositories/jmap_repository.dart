import 'package:leithmail/core/usecase/app_failure.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/jmap_session.dart';

abstract class JmapRepository {
  /// Fetches a [JmapSession] by performing a GET request against [jmapSessionEndpoint]
  /// (typically `/.well-known/jmap`) authenticated with [credentials].
  ///
  /// Throws [JmapRepositoryException] on any failure.
  Future<JmapSession> fetchSession({
    required Uri jmapSessionEndpoint,
    required Credentials credentials,
  });
}

enum JmapRepositoryExceptionKind {
  unauthorized,
  serverError,
  parseError,
  networkError,
}

class JmapRepositoryException implements Exception {
  final JmapRepositoryExceptionKind kind;
  final String message;

  const JmapRepositoryException({required this.kind, required this.message});

  @override
  String toString() => 'JmapRepositoryException(${kind.name}): $message';

  AppFailure mapToAppFailure() => switch (kind) {
    JmapRepositoryExceptionKind.unauthorized => AuthFailure(message),
    JmapRepositoryExceptionKind.serverError => JmapFailure(message),
    JmapRepositoryExceptionKind.parseError => JmapFailure(message),
    JmapRepositoryExceptionKind.networkError => NetworkFailure(message),
  };
}
