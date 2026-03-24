import 'package:fpdart/fpdart.dart';
import 'package:leithmail/core/usecase/app_failure.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/domain/entities/oidc_provider_metadata.dart';
import 'package:leithmail/domain/repositories/oidc_repository.dart';

class DiscoverOidcProviderUsecase
    extends UsecaseBase<EmailAddress, OidcProviderMetadata> {
  final OidcRepository _repository;
  DiscoverOidcProviderUsecase(this._repository);

  @override
  Future<Either<AppFailure, OidcProviderMetadata>> execute(
    EmailAddress input,
  ) async {
    try {
      final metadata = await _repository.discoverProvider(input);
      if (metadata == null) {
        return left(NotFoundFailure());
      }
      return right(metadata);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}

class AuthenticateOidcUsecase
    extends UsecaseBase<OidcProviderMetadata, CredentialsOidc> {
  final OidcRepository _repository;
  AuthenticateOidcUsecase(this._repository);

  @override
  Future<Either<AppFailure, CredentialsOidc>> execute(
    OidcProviderMetadata input,
  ) async {
    try {
      return right(await _repository.authenticate(input));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}

class RefreshOidcCredentialsUsecase
    extends UsecaseBase<CredentialsOidc, CredentialsOidc> {
  final OidcRepository _repository;
  RefreshOidcCredentialsUsecase(this._repository);

  @override
  Future<Either<AppFailure, CredentialsOidc>> execute(
    CredentialsOidc input,
  ) async {
    try {
      return right(await _repository.refresh(input));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}
