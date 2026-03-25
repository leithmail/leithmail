import 'package:fpdart/fpdart.dart';
import 'package:leithmail/core/usecase/app_failure.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/jmap_session.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/oidc_repository.dart';

abstract class JmapUsecaseBaseInput {
  final AccountId accountId;
  const JmapUsecaseBaseInput(this.accountId);
}

class JmapUsecaseBindings {
  final AccountRepository accountRepository;
  final OidcRepository oidcRepository;
  final JmapRepository jmapRepository;

  JmapUsecaseBindings({
    required this.accountRepository,
    required this.oidcRepository,
    required this.jmapRepository,
  });
}

abstract class JmapUsecaseBase<Input extends JmapUsecaseBaseInput, Output>
    extends UsecaseBase<Input, Output> {
  final JmapUsecaseBindings bindings;

  const JmapUsecaseBase({required this.bindings});

  Future<Either<AppFailure, Output>> executeJmap(
    Input input,
    JmapSession session,
  );

  @override
  Future<Either<AppFailure, Output>> execute(Input input) async {
    Account? account = await bindings.accountRepository.getById(
      input.accountId,
    );
    if (account == null) {
      return left(NotFoundFailure("Account not found."));
    }
    if (account.credentials.isExpired) {
      // TODO: refresh credentials and session and store them in accountRepository
    }
    JmapSession session = account.jmapSession;
    // TODO: wrap with retry mechanism for stale session or credentials
    return executeJmap(input, session);
  }
}

class JmapRepository {}
