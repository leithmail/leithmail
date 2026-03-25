import 'package:flutter/widgets.dart';
import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/domain/entities/credentials.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/domain/entities/jmap_metadata.dart';
import 'package:leithmail/domain/entities/oidc_provider_metadata.dart';
import 'package:leithmail/domain/usecases/account_usecases.dart';
import 'package:leithmail/domain/usecases/oidc_usecases.dart';
import 'package:leithmail/presentation/base/controller_base.dart';
import 'package:signals/signals.dart';
import 'package:leithmail/core/usecase/usecase_result.dart';
import 'package:leithmail/domain/entities/account.dart';

typedef AddAccountControllerBindings = ({
  AddAccountUsecase addAccountUsecase,
  DiscoverOidcProviderUsecase discoverOidcProviderUsecase,
  AuthenticateOidcUsecase authenticateOidcUsecase,
});

typedef AddAccountControllerInputs = ({
  void Function() onAccountAdded,
  bool canGoBack,
});

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

  Future<void> addAccount(String email) async {
    isLoading.value = true;
    errorMessage.value = null;

    final EmailAddress emailAddress;
    try {
      emailAddress = EmailAddress.parse(email.trim());
    } catch (e) {
      Log.warning('[AddAccountController] invalid email address', e);
      errorMessage.value = 'Invalid email address.';
      isLoading.value = false;
      return;
    }

    // Step 1: OIDC discovery
    final OidcProviderMetadata metadata;
    switch (await bindings.discoverOidcProviderUsecase(emailAddress)) {
      case Success(:final data):
        metadata = data;
      case Failure(:final failure):
        errorMessage.value = 'Failed to discover OIDC provider: $failure';
        isLoading.value = false;
        return;
    }

    // Step 2: Authenticate
    final CredentialsOidc credentials;
    switch (await bindings.authenticateOidcUsecase((
      oidcProviderMetadata: metadata,
      email: emailAddress,
    ))) {
      case Success(:final data):
        credentials = data;
      case Failure(:final failure):
        errorMessage.value = 'Authentication failed: $failure';
        isLoading.value = false;
        return;
    }

    // Step 3: Persist account (JMAP metadata mocked for now)
    final account = Account(
      emailAddress: emailAddress,
      credentials: credentials,
      jmap: JmapMetadata(
        apiUrl: Uri.parse('http://mock'),
        downloadUrl: Uri.parse('http://mock'),
        uploadUrl: Uri.parse('http://mock'),
        eventSourceUrl: Uri.parse('http://mock'),
      ),
    );

    switch (await bindings.addAccountUsecase(account)) {
      case Success():
        isLoading.value = false;
        inputs.onAccountAdded();
        return;
      case Failure(:final failure):
        errorMessage.value = 'Failed to add account: $failure';
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
