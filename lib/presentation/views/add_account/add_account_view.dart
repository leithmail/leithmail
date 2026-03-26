import 'package:flutter/material.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller.dart';

class AddAccountView
    extends
        ControllerWidget<
          AddAccountController,
          AddAccountControllerBindings,
          AddAccountControllerInputs
        > {
  const AddAccountView({
    super.key,
    required super.factory,
    required super.inputs,
  });

  Future<void> _addAccount(
    BuildContext context,
    AddAccountController controller,
  ) async {
    if (controller.isLoading.value) {
      return;
    }
    final isSuccess = await controller.addAccount(
      controller.emailInputController.text,
    );
    if (isSuccess) {
      controller.inputs.onAccountAdded();
    }
  }

  @override
  Widget build(BuildContext context, AddAccountController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: controller.inputs.canGoBack
          ? AppBar(
              leading: BackButton(
                onPressed: () => controller.inputs.onBack?.call(),
              ),
              backgroundColor: Colors.transparent,
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Leithmail',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your email account to get started.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: controller.emailInputController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  onSubmitted: (_) => _addAccount(context, controller),
                ),
                const SizedBox(height: 12),
                Watch((context) {
                  final error = controller.errorMessage.value;
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      error,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  );
                }, debugLabel: 'AddAccountView.errorMessage'),
                Watch((context) {
                  final isLoading = controller.isLoading.value;
                  return FilledButton(
                    onPressed: () => _addAccount(context, controller),
                    style: FilledButton.styleFrom(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add account'),
                  );
                }, debugLabel: 'AddAccountView.AddAccountButton'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
