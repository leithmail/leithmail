import 'package:fpdart/fpdart.dart';
import 'package:leithmail/core/usecase/app_failure.dart';
import 'package:leithmail/core/usecase/usecase_base.dart';
import 'package:leithmail/domain/entities/mock_mailbox.dart';
import 'package:leithmail/domain/repositories/mailbox_repository.dart';

class GetMailboxesUsecase extends UsecaseBase<NoInput, List<MockMailbox>> {
  GetMailboxesUsecase(this._repository);

  final MailboxRepository _repository;

  @override
  Future<Either<AppFailure, List<MockMailbox>>> execute(NoInput _) async {
    try {
      final mailboxes = await _repository.getMailboxes();
      return right(mailboxes);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}
