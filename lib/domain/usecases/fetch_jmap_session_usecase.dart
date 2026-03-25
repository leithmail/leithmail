import 'package:fpdart/fpdart.dart';
import 'package:leithmail/core/usecase/app_failure.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/jmap_session.dart';
import 'package:leithmail/domain/repositories/jmap_repository.dart';

class FetchJmapSessionInput {
  final Uri jmapSessionUri;
  final Credentials credentials;

  const FetchJmapSessionInput({
    required this.jmapSessionUri,
    required this.credentials,
  });
}

class FetchJmapSessionUsecase
    extends UsecaseBase<FetchJmapSessionInput, JmapSession> {
  final JmapRepository _jmapRepository;

  const FetchJmapSessionUsecase(this._jmapRepository);

  @override
  Future<Either<AppFailure, JmapSession>> execute(
    FetchJmapSessionInput input,
  ) async {
    try {
      final session = await _jmapRepository.fetchSession(
        jmapSessionUri: input.jmapSessionUri,
        credentials: input.credentials,
      );
      return right(session);
    } on JmapRepositoryException catch (e) {
      return left(_mapException(e));
    }
  }

  AppFailure _mapException(JmapRepositoryException e) => switch (e.kind) {
    JmapRepositoryExceptionKind.unauthorized => AuthFailure(e.message),
    JmapRepositoryExceptionKind.serverError => JmapFailure(e.message),
    JmapRepositoryExceptionKind.parseError => JmapFailure(e.message),
    JmapRepositoryExceptionKind.networkError => NetworkFailure(e.message),
  };
}
