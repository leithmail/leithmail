import 'package:fpdart/fpdart.dart';
import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/core/usecase/app_failure.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';

// ---------------------------------------------------------------------------
// NoInput
// ---------------------------------------------------------------------------

/// Type for use cases that require no input.
/// Pass [noInput] at the call site: `await myUseCase(noInput)`.
typedef NoInput = void;

/// Sentinel value for use cases that take no input.
// ignore: prefer_void_to_null
const Null noInput = null;

// ---------------------------------------------------------------------------
// UsecaseBase
// ---------------------------------------------------------------------------

/// Base class for all use cases.
///
/// Subclasses implement [execute], which returns [Either<AppFailure, T>].
/// Callers invoke the use case via [call], which:
///   - logs invocation and outcome
///   - wraps the [Either] result into [UsecaseResult]
///   - catches any unexpected exceptions that escape [execute] and converts
///     them to [Failure<UnexpectedFailure>]
///
/// Example with input:
/// ```dart
/// class FetchMailboxesUseCase extends UsecaseBase<Session, List<Mailbox>> {
///   FetchMailboxesUseCase(this._repo);
///
///   @override
///   String get name => 'FetchMailboxesUseCase';
///
///   @override
///   Future<Either<AppFailure, List<Mailbox>>> execute(Session input) async {
///     try {
///       return right(await _repo.getMailboxes(input));
///     } on SomeNetworkException catch (e) {
///       return left(NetworkFailure(e.message));
///     }
///   }
/// }
///
/// // call site:
/// final result = await fetchMailboxes(session);
/// switch (result) {
///   case Success(:final data): ...
///   case Failure(:final failure): ...
/// }
/// ```
///
/// Example with no input:
/// ```dart
/// class GetActiveAccountUseCase extends UsecaseBase<NoInput, Account?> {
///   @override
///   String get name => 'GetActiveAccountUseCase';
///
///   @override
///   Future<Either<AppFailure, Account?>> execute(NoInput _) async { ... }
/// }
///
/// // call site:
/// final result = await getActiveAccount(noInput);
/// ```
abstract class UsecaseBase<Input, Output> {
  const UsecaseBase();

  /// Human-readable name used in log messages.
  String get name;

  /// The core logic. Implement this in subclasses.
  ///
  /// Return [right(value)] on success.
  /// Return [left(AppFailure)] for expected, recoverable domain failures.
  /// Unexpected exceptions that escape will be caught by [call] and wrapped
  /// in [UnexpectedFailure].
  Future<Either<AppFailure, Output>> execute(Input input);

  /// Invokes the use case, logging start and outcome.
  /// Always returns [UsecaseResult] — never throws.
  Future<UsecaseResult<Output>> call(Input input) async {
    Log.debug('[$name] started');
    try {
      final either = await execute(input);
      return either.fold(
        (failure) {
          Log.warning('[$name] failure', failure);
          return Failure(failure);
        },
        (data) {
          Log.debug('[$name] success');
          return Success(data);
        },
      );
    } catch (e, st) {
      Log.error('[$name] unexpected error', e, st);
      return Failure(UnexpectedFailure(e, st));
    }
  }
}
