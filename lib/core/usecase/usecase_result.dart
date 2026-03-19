import 'package:leithmail/core/usecase/app_failure.dart';

sealed class UsecaseResult<T> {
  const UsecaseResult();
}

class Success<T> extends UsecaseResult<T> {
  const Success(this.data);
  final T data;

  @override
  String toString() => 'Success($data)';
}

class Failure<T> extends UsecaseResult<T> {
  const Failure(this.failure);
  final AppFailure failure;

  @override
  String toString() => 'Failure($failure)';
}
