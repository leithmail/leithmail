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

typedef AddAccountControllerBindings = ({
  AddAccountUsecase addAccountUsecase,
  DiscoverOidcProviderUsecase discoverOidcProviderUsecase,
  AuthenticateOidcUsecase authenticateOidcUsecase,
  FetchJmapSessionUsecase fetchJmapSessionUsecase,
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

    // Parse Email
    final EmailAddress emailAddress;
    try {
      emailAddress = EmailAddress.parse(email.trim());
    } catch (e) {
      Log.warning('[AddAccountController] invalid email address', e);
      errorMessage.value = 'Invalid email address.';
      isLoading.value = false;
      return;
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
        return;
    }

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
