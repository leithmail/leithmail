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
  GetAuthenticatedAccountUsecase getAuthenticatedAccountUsecase,
});

class AddAccountControllerInputs {
  final void Function() onSuccess;
  final void Function()? onCancel;
  final FinishAuthFlowOidcUsecaseInput? oidcCallbackData;

  const AddAccountControllerInputs({
    required this.onSuccess,
    this.onCancel,
    this.oidcCallbackData,
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
    final oidcCallbackData = inputs.oidcCallbackData;
    if (oidcCallbackData != null) {
      processOidcCallbackData(oidcCallbackData);
      return;
    }
  }

  Future<void> processOidcCallbackData(
    FinishAuthFlowOidcUsecaseInput oidcCallbackData,
  ) async {
    isLoading.value = true;
    final finishAuthFlowResult = await bindings.finishAuthFlowOidcUsecase(
      oidcCallbackData,
    );
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
        await finishAuthFlow(emailAddress, data.credentials);
        break;
      case Failure():
        errorMessage.value = 'Authentication failed.';
        isLoading.value = false;
        break;
    }
  }

  Future<void> addAccount(String email) async {
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
      return;
    }

    // Check if account already exists and credentials are still valid
    final getAuthAccountResult = await bindings.getAuthenticatedAccountUsecase(
      AccountId(emailAddress.value),
    );
    switch (getAuthAccountResult) {
      case Success(:final data):
        if (data != null) {
          return finishAuthFlow(emailAddress, data.credentials);
        }
        break;
      case Failure():
      // nothing to do here, continue with the authentication flow
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
        return;
    }

    // Authenticate (WEB only)
    if (kIsWeb) {
      final uriResult = await bindings.getAuthUrlOidcUsecase((
        id: email,
        credentials: oidcMetadata,
        loginHint: email,
      ));
      switch (uriResult) {
        case Success(:final data):
          web.window.location.href = data.toString();
          return; // flow continues in processOidcCallbackData after redirect
        case Failure():
          errorMessage.value = 'Unable to redirect to OIDC provider.';
          isLoading.value = false;
          return;
      }
    }

    // Authenticate (other platforms)
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
        return;
    }

    return finishAuthFlow(emailAddress, credentials);
  }

  Future<void> finishAuthFlow(
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
        return;
    }

    // Persist account
    final account = Account(
      emailAddress: emailAddress,
      credentials: credentials,
      jmapSession: jmapSession,
    );

    switch (await bindings.addAccountUsecase(account)) {
      case Success():
        inputs.onSuccess();
        return;
      case Failure():
        errorMessage.value = 'Failed to add account.';
        isLoading.value = false;
        return;
    }
  }

  @override
  void onDispose() {
    emailInputController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
