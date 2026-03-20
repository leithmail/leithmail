import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/presentation/account_settings/account_settings_controller.dart';
import 'package:leithmail/presentation/account_settings/account_settings_screen.dart';
import 'package:leithmail/presentation/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/add_account/add_account_screen.dart';
import 'package:leithmail/presentation/dashboard/dashboard_controller.dart';

class AccountPanel extends StatelessWidget {
  const AccountPanel({
    super.key,
    required this.controller,
    required this.addAccountController,
    required this.accountSettingsController,
    required this.activeAccount,
    required this.onAccountAdded,
    required this.onAccountRemoved,
  });

  final DashboardController controller;
  final AddAccountController addAccountController;
  final AccountSettingsController accountSettingsController;
  final ReadonlySignal<Account?> activeAccount;
  final VoidCallback onAccountAdded;
  final VoidCallback onAccountRemoved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          left: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                Text(
                  'Accounts',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: controller.closeAccountPanel,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(),
          // Account list
          Expanded(
            child: Watch((context) {
              final accounts = controller.accounts.value;
              final currentAccount = activeAccount.value;
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...accounts.map(
                    (account) => _AccountTile(
                      account: account,
                      isActive: account.id == currentAccount?.id,
                      onTap: () => controller.switchAccount(account.id),
                    ),
                  ),
                  const Divider(),
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
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      controller.closeAccountPanel();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddAccountScreen(
                            controller: addAccountController,
                            canGoBack: true,
                            onSuccess: () {
                              Navigator.of(context).pop();
                              onAccountAdded();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }, debugLabel: 'AccountPanel.AccountList'),
          ),
          const Divider(),
          // Account settings
          Watch((context) {
            final current = activeAccount.value;
            if (current == null) return const SizedBox.shrink();
            return ListTile(
              dense: true,
              leading: Icon(
                Icons.settings_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Account settings',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AccountSettingsScreen(
                      account: current,
                      controller: accountSettingsController,
                      onRemove: () {
                        Navigator.of(context).pop();
                        onAccountRemoved();
                      },
                    ),
                  ),
                );
              },
            );
          }, debugLabel: 'AccountPanel.AccountSettings'),
        ],
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

  final Account account;
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
      subtitle: isActive
          ? Text(
              'active',
              style: TextStyle(fontSize: 11, color: colorScheme.primary),
            )
          : null,
      trailing: isActive
          ? Icon(Icons.check, size: 16, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
