import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';
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
  GetAuthUrlOidcUsecase getAuthUrlOidcUsecase,
  FinishAuthFlowOidcUsecase finishAuthFlowOidcUsecase,
  RefreshAndGetAccountUsecase refreshAndGetAccountUsecase,
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
        await finishAuthFlow(
          accountId: data.accountId,
          credentials: data.credentials,
          jmapSessionEndpoint: data.jmapSessionEndpoint,
        );
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

    await Future.delayed(const Duration(milliseconds: 300));

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
    final jmapSessionEndpoint = Uri.https(
      emailAddress.domain,
      '/.well-known/jmap',
    );
    final accountId = AccountId(emailAddress.value);

    // Check if account already exists and credentials are still valid
    final getAccountResult = await bindings.refreshAndGetAccountUsecase(
      accountId,
    );
    switch (getAccountResult) {
      case Success(:final data):
        if (data != null) {
          await finishAuthFlow(
            accountId: accountId,
            credentials: data.credentials,
            jmapSessionEndpoint: jmapSessionEndpoint,
          );
          return;
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
        accountId: accountId,
        credentials: oidcMetadata,
        jmapSessionEndpoint: jmapSessionEndpoint,
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

    await finishAuthFlow(
      accountId: AccountId(emailAddress.value),
      credentials: credentials,
      jmapSessionEndpoint: jmapSessionEndpoint,
    );
  }

  Future<void> finishAuthFlow({
    required AccountId accountId,
    required Credentials credentials,
    required Uri jmapSessionEndpoint,
  }) async {
    switch (await bindings.addAccountUsecase((
      jmapSessionEndpoint: jmapSessionEndpoint,
      accountId: accountId,
      credentials: credentials,
    ))) {
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
