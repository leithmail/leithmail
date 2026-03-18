import 'package:leithmail/app_routes.dart';
import 'package:leithmail/core/error/failure.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';
import 'package:leithmail/presentation/base/base_controller.dart';
import 'package:get/get.dart';

sealed class DashboardState {}

class DashboardStateLoading extends DashboardState {}

class DashboardStateLoaded extends DashboardState {
  final Account account;
  DashboardStateLoaded(this.account);
}

class DashboardStateError extends DashboardState {
  final Failure failure;
  DashboardStateError(this.failure);
}

class DashboardController extends BaseController {
  final AccountRepository _accountRepository;
  final ActiveAccountRepository _activeAccountRepository;

  DashboardController(this._accountRepository, this._activeAccountRepository);

  final state = Rx<DashboardState>(DashboardStateLoading());
  set _state(DashboardState s) => state.value = s;

  @override
  void onInit() {
    super.onInit();
    loadActiveAccount();
  }

  Future<void> loadActiveAccount() async {
    _state = DashboardStateLoading();
    try {
      final accountId = await _activeAccountRepository.getActiveAccountId();
      if (accountId == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      final account = await _accountRepository.getById(accountId);
      if (account == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      _state = DashboardStateLoaded(account);
    } catch (e, st) {
      final failure = Failure(e, st);
      _state = DashboardStateError(failure);
      handleFailure(failure);
    }
  }
}
