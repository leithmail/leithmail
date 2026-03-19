import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/presentation/add_account/add_account_controller.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({
    super.key,
    required this.controller,
    required this.onSuccess,
    this.canGoBack = false,
  });

  final AddAccountController controller;

  /// Called after an account is successfully added.
  /// The caller (app.dart) is responsible for navigating to the dashboard.
  final VoidCallback onSuccess;

  final bool canGoBack;

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await widget.controller.addAccount(_emailController.text);
    if (success && mounted) {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: widget.canGoBack
          ? AppBar(
              leading: const BackButton(),
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
                  'leithmail',
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
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                Watch((context) {
                  final error = widget.controller.errorMessage.value;
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      error,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  );
                }),
                Watch((context) {
                  final isLoading = widget.controller.isLoading.value;
                  return FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add account'),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
