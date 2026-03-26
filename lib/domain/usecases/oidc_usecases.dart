import 'package:fpdart/fpdart.dart';
import 'package:leithmail/core/usecase/app_failure.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/repositories/oidc_repository.dart';

class DiscoverOidcProviderUsecase extends UsecaseBase<String, OidcCredentials> {
  final OidcRepository _repository;
  DiscoverOidcProviderUsecase(this._repository);

  @override
  Future<Either<AppFailure, OidcCredentials>> execute(String domain) async {
    try {
      final credentials = await _repository.discoverProvider(domain);
      return right(credentials);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}

typedef AuthenticateOidcUsecaseInput = ({
  OidcCredentials credentials,
  String? loginHint,
});

class AuthenticateOidcUsecase
    extends UsecaseBase<AuthenticateOidcUsecaseInput, OidcCredentials> {
  final OidcRepository _repository;
  AuthenticateOidcUsecase(this._repository);

  @override
  Future<Either<AppFailure, OidcCredentials>> execute(
    AuthenticateOidcUsecaseInput input,
  ) async {
    try {
      return right(
        await _repository.authenticate(
          input.credentials,
          loginHint: input.loginHint,
        ),
      );
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}

class RefreshOidcCredentialsUsecase
    extends UsecaseBase<OidcCredentials, OidcCredentials> {
  final OidcRepository _repository;
  RefreshOidcCredentialsUsecase(this._repository);

  @override
  Future<Either<AppFailure, OidcCredentials>> execute(
    OidcCredentials input,
  ) async {
    try {
      return right(await _repository.refresh(input));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}

typedef GetAuthUrlOidcUsecaseInput = ({
  String id,
  OidcCredentials credentials,
  String? loginHint,
});

class GetAuthUrlOidcUsecase
    extends UsecaseBase<GetAuthUrlOidcUsecaseInput, Uri> {
  final OidcRepository _repository;
  GetAuthUrlOidcUsecase(this._repository);

  @override
  Future<Either<AppFailure, Uri>> execute(
    GetAuthUrlOidcUsecaseInput input,
  ) async {
    try {
      return right(
        await _repository.getAuthUrl(
          input.id,
          input.credentials,
          loginHint: input.loginHint,
        ),
      );
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}

typedef FinishAuthFlowOidcUsecaseInput = ({String state, String code});

typedef FinishAuthFlowOidcUsecaseOutput = ({
  String id,
  OidcCredentials credentials,
});

class FinishAuthFlowOidcUsecase
    extends
        UsecaseBase<
          FinishAuthFlowOidcUsecaseInput,
          FinishAuthFlowOidcUsecaseOutput
        > {
  final OidcRepository _repository;
  FinishAuthFlowOidcUsecase(this._repository);

  @override
  Future<Either<AppFailure, FinishAuthFlowOidcUsecaseOutput>> execute(
    FinishAuthFlowOidcUsecaseInput input,
  ) async {
    try {
      final result = await _repository.finishAuthFlow(
        state: input.state,
        code: input.code,
      );
      return right((id: result.id, credentials: result.credentials));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}
