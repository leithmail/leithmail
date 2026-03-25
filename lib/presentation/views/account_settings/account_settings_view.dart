import 'package:flutter/material.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/presentation/views/account_settings/account_settings_controller.dart';

class AccountSettingsView
    extends
        ControllerWidget<
          AccountSettingsController,
          AccountSettingsControllerBindings,
          AccountSettingsControllerInputs
        > {
  const AccountSettingsView({
    super.key,
    required super.factory,
    required super.inputs,
  });

  Future<bool> _confirmAccountRemovalDialog(
    BuildContext context,
    EmailAddress email,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove account'),
        content: Text(
          'Remove ${email.value}? '
          'This will delete all local data for this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, AccountSettingsController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final initials = controller.inputs.account.emailAddress.value
        .substring(0, 2)
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Account settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Account card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.inputs.account.emailAddress.value,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.inputs.account.jmapSession.apiUrl
                              .toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          // Remove account
          Watch((context) {
            final isLoading = controller.isLoading.value;
            final error = controller.errorMessage.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
                  title: Text(
                    'Remove account',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  subtitle: const Text('Removes this account from the app.'),
                  trailing: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: isLoading
                      ? null
                      : () async {
                          final confirm = await _confirmAccountRemovalDialog(
                            context,
                            controller.inputs.account.emailAddress,
                          );
                          if (confirm) {
                            await controller.removeAccount();
                          }
                        },
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      error,
                      style: TextStyle(fontSize: 12, color: colorScheme.error),
                    ),
                  ),
              ],
            );
          }, debugLabel: 'AccountSettingsView.RemoveAccount'),
          const Divider(),
        ],
      ),
    );
  }
}
