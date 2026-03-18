import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leithmail/app_routes.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/domain/entities/credentials_oidc.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/domain/entities/jmap_metadata.dart';
import 'package:leithmail/domain/repositories/account_repository.dart';
import 'package:leithmail/domain/repositories/active_account_repository.dart';
import 'package:leithmail/presentation/base/base_controller.dart';

sealed class LoginState {}

class LoginStateInitial extends LoginState {}

class LoginStateLoading extends LoginState {}

class LoginStateError extends LoginState {
  final String message;
  LoginStateError(this.message);
}

class LoginController extends BaseController {
  final AccountRepository _accountRepository;
  final ActiveAccountRepository _activeAccountRepository;

  LoginController(this._accountRepository, this._activeAccountRepository);

  final state = Rx<LoginState>(LoginStateInitial());
  final emailController = TextEditingController();

  set _state(LoginState s) => state.value = s;

  Future<void> onNext() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    _state = LoginStateLoading();
    try {
      // For now just create a minimal account and set it active
      // OIDC autodiscovery will plug in here later
      final account = Account(
        emailAddress: EmailAddress.parse(email),
        credentials: CredentialsOidc(
          accessToken: "",
          refreshToken: "",
          expiry: DateTime.now(),
        ),
        jmap: JmapMetadata(
          apiUrl: Uri.parse("dummy"),
          downloadUrl: Uri.parse("dummy"),
          uploadUrl: Uri.parse("dummy"),
          eventSourceUrl: Uri.parse("dummy"),
        ),
      );
      await _accountRepository.save(account);
      await _activeAccountRepository.setActiveAccountId(account.id);
      Get.offNamed(AppRoutes.dashboard);
    } catch (e) {
      _state = LoginStateError(e.toString());
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
