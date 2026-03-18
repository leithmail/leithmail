import 'package:get/get.dart';
import 'package:leithmail/app_routes.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';
import 'package:leithmail/presentation/base/base_controller.dart';
import 'package:leithmail/presentation/dashboard/dashboard_state.dart';

class DashboardController extends BaseController {
  final AccountRepository _accountRepository;
  final ActiveAccountRepository _activeAccountRepository;

  DashboardController(this._accountRepository, this._activeAccountRepository);

  final state = Rx<DashboardState>(DashboardStateLoading());

  set _state(DashboardState s) => state.value = s;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    _state = DashboardStateLoading();
    try {
      final accounts = await _accountRepository.getAll();
      final activeAccountId = await _activeAccountRepository
          .getActiveAccountId();
      _state = DashboardStateLoaded(
        accounts: accounts,
        activeAccountId: activeAccountId,
      );
    } catch (e) {
      _state = DashboardStateError(e.toString());
    }
  }

  Future<void> setActiveAccount(AccountId id) async {
    await _activeAccountRepository.setActiveAccountId(id);
    await loadAccounts();
  }

  Future<void> deleteAccount(AccountId id) async {
    await _accountRepository.delete(id);
    final current = await _activeAccountRepository.getActiveAccountId();
    if (current == id) {
      await _activeAccountRepository.clear();
    }
    await loadAccounts();
  }

  void goToLogin() => Get.toNamed(AppRoutes.login);
}
