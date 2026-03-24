import 'package:fpdart/fpdart.dart';
import 'package:leithmail/core/usecase/app_failure.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/domain/entities/mock_email.dart';
import 'package:leithmail/domain/repositories/email_repository.dart';

class GetEmailsUsecase extends UsecaseBase<String, List<MockEmail>> {
  GetEmailsUsecase(this._repository);

  final EmailRepository _repository;

  @override
  Future<Either<AppFailure, List<MockEmail>>> execute(String mailboxId) async {
    try {
      final emails = await _repository.getEmails(mailboxId);
      return right(emails);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}
