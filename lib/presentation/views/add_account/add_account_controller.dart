import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/domain/entities/jmap_session.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/domain/usecases/fetch_jmap_session_usecase.dart';
import 'package:leithmail/domain/usecases/oidc_usecases.dart';
import 'package:leithmail/presentation/base/controller_base.dart';
import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:web/web.dart' as web;

typedef AddAccountControllerBindings = ({
  AddAccountUsecase addAccountUsecase,
  DiscoverOidcProviderUsecase discoverOidcProviderUsecase,
  AuthenticateOidcUsecase authenticateOidcUsecase,
  FetchJmapSessionUsecase fetchJmapSessionUsecase,
  GetAuthUrlOidcUsecase getAuthUrlOidcUsecase,
  FinishAuthFlowOidcUsecase finishAuthFlowOidcUsecase,
});

class AddAccountControllerInputs {
  final void Function() onAccountAdded;
  final void Function()? onBack;
  final bool canGoBack;
  final String? authCode;
  final String? authState;

  const AddAccountControllerInputs({
    required this.onAccountAdded,
    required this.canGoBack,
    this.authCode,
    this.authState,
    this.onBack,
  });
}

class AddAccountControllerFactory
    extends
        ControllerFactoryBase<
          AddAccountController,
          AddAccountControllerBindings,
          AddAccountControllerInputs
        > {
  AddAccountControllerFactory({required super.bindings});

  @override
  AddAccountController create(AddAccountControllerInputs inputs) =>
      AddAccountController(bindings: bindings, inputs: inputs);
}

class AddAccountController
    extends
        ControllerBase<
          AddAccountControllerBindings,
          AddAccountControllerInputs
        > {
  final Signal<bool> isLoading = signal(
    false,
    debugLabel: 'AddAccountController.isLoading',
  );
  final Signal<String?> errorMessage = signal(
    null,
    debugLabel: 'AddAccountController.errorMessage',
  );

  final emailInputController = TextEditingController();

  AddAccountController({required super.bindings, required super.inputs});

  @override
  Future<void> onInit() async {
    final authCode = inputs.authCode;
    final authState = inputs.authState;
    if (authCode != null && authState != null) {
      isLoading.value = true;
      final finishAuthFlowResult = await bindings.finishAuthFlowOidcUsecase((
        code: authCode,
        state: authState,
      ));
      switch (finishAuthFlowResult) {
        case Success(:final data):
          final EmailAddress emailAddress;
          try {
            emailAddress = EmailAddress.parse(data.id);
          } catch (e) {
            Log.warning('[$runtimeType] invalid email address', e);
            errorMessage.value = 'Invalid email address.';
            isLoading.value = false;
            return;
          }
          final isSuccess = await finishAuthFlow(
            emailAddress,
            data.credentials,
          );
          if (isSuccess) {
            // redirect to the app root to clear any auth callback query parameters from the URL
            web.window.location.href = Uri.base.origin;
            return;
          }
          break;
        case Failure():
          errorMessage.value = 'Authentication failed.';
          isLoading.value = false;
          break;
      }
    }
  }

  Future<bool> addAccount(String email) async {
    isLoading.value = true;
    errorMessage.value = null;

    // Parse Email
    final EmailAddress emailAddress;
    try {
      emailAddress = EmailAddress.parse(email.trim());
    } catch (e) {
      Log.warning('[$runtimeType] invalid email address', e);
      errorMessage.value = 'Invalid email address.';
      isLoading.value = false;
      return false;
    }

    // OIDC discovery
    final OidcCredentials oidcMetadata;
    switch (await bindings.discoverOidcProviderUsecase(emailAddress.domain)) {
      case Success(:final data):
        oidcMetadata = data;
        break;
      case Failure():
        errorMessage.value = 'Failed to discover OIDC provider.';
        isLoading.value = false;
        return false;
    }

    if (kIsWeb) {
      final uriResult = await bindings.getAuthUrlOidcUsecase((
        id: email,
        credentials: oidcMetadata,
        loginHint: email,
      ));
      switch (uriResult) {
        case Success(:final data):
          web.window.location.href = data.toString();
          return false; // flow continues in finishAuthFlow after redirect
        case Failure():
          errorMessage.value = 'Unable to redirect to OIDC provider.';
          isLoading.value = false;
          return false;
      }
    }

    // Authenticate
    final OidcCredentials credentials;
    switch (await bindings.authenticateOidcUsecase((
      credentials: oidcMetadata,
      loginHint: emailAddress.toString(),
    ))) {
      case Success(:final data):
        credentials = data;
        break;
      case Failure():
        errorMessage.value = 'Authentication failed.';
        isLoading.value = false;
        return false;
    }

    return finishAuthFlow(emailAddress, credentials);
  }

  Future<bool> finishAuthFlow(
    EmailAddress emailAddress,
    Credentials credentials,
  ) async {
    // Fetch Jmap Session
    final JmapSession jmapSession;
    switch (await bindings.fetchJmapSessionUsecase(
      FetchJmapSessionInput(
        jmapSessionUri: Uri.https(emailAddress.domain, '/.well-known/jmap'),
        credentials: credentials,
      ),
    )) {
      case Success(:final data):
        jmapSession = data;
        break;
      case Failure():
        errorMessage.value = 'Unable to initiate JMAP session.';
        isLoading.value = false;
        return false;
    }

    // Persist account
    final account = Account(
      emailAddress: emailAddress,
      credentials: credentials,
      jmapSession: jmapSession,
    );

    switch (await bindings.addAccountUsecase(account)) {
      case Success():
        return true;
      case Failure(:final failure):
        errorMessage.value = 'Failed to add account: $failure';
        isLoading.value = false;
        return false;
    }
  }

  @override
  void onDispose() {
    emailInputController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
