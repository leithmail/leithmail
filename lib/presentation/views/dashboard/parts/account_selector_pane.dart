import 'package:flutter/material.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/presentation/models/account_summary.dart';
import 'package:leithmail/presentation/views/account_settings/account_settings_view.dart';
import 'package:leithmail/presentation/views/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/views/add_account/add_account_view.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller.dart';

class AccountSelectorPane extends StatelessWidget {
  const AccountSelectorPane({
    super.key,
    required this.onClose,
    required this.controller,
  });

  final void Function() onClose;
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accounts section label
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Accounts',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // Account list
            Expanded(
              child: ListView(
                children: [
                  ...controller.inputs.accountSummariesList.value.expand(
                    (account) => [
                      _AccountTile(
                        account: account,
                        isActive:
                            account.id ==
                            controller.inputs.activeAccount.value.id,
                        onTap: () => _onSelectAccount(account.id),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  ListTile(
                    dense: true,
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      'Add account',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    onTap: () => _onAddAccount(context),
                  ),
                ],
              ),
            ),
            // Account settings
            ListTile(
              dense: true,
              leading: Icon(
                Icons.settings_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Account settings',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              onTap: () => _onOpenAccountSettings(context),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddAccount(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => AddAccountView(
          factory: controller.bindings.addAccountControllerFactory,
          inputs: AddAccountControllerInputs(
            onSuccess: () {
              onClose();
              navigator.popUntil((route) => route.isFirst);
              controller.inputs.onAccountSwitched();
            },
            onCancel: () => navigator.pop(),
          ),
        ),
      ),
    );
  }

  Future<void> _onSelectAccount(AccountId id) async {
    await controller.setActiveAccount(id);
    onClose();
    controller.inputs.onAccountSwitched();
  }

  void _onOpenAccountSettings(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => AccountSettingsView(
          factory: controller.bindings.accountSettingsControllerFactory,
          inputs: (
            account: controller.inputs.activeAccount.value,
            onAccountRemoved: () {
              onClose();
              navigator.popUntil((route) => route.isFirst);
              controller.inputs.onAccountSwitched();
            },
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.isActive,
    required this.onTap,
  });

  final AccountSummary account;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = account.emailAddress.value.substring(0, 2).toUpperCase();

    return ListTile(
      dense: true,
      selected: isActive,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: isActive
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isActive
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(
        account.emailAddress.value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isActive
          ? Icon(Icons.check, size: 16, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
