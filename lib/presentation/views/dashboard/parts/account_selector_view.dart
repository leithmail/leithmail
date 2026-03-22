import 'package:flutter/material.dart';
import 'package:leithmail/presentation/models/account_summary.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/presentation/views/account_settings/account_settings_view.dart';
import 'package:leithmail/presentation/views/add_account/add_account_view.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller.dart';

class AccountSelectorView extends StatelessWidget {
  const AccountSelectorView({super.key, required this.controller});

  final DashboardController controller;

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
                  onPressed: controller.closeAccountSelectorView,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(),
          // Account list
          Expanded(
            child: Watch((context) {
              final accounts = controller.inputs.accountSummariesList.value;
              final currentAccount = controller.inputs.activeAccount.value;
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...accounts.map(
                    (account) => _AccountTile(
                      account: account,
                      isActive: account.id == currentAccount.id,
                      onTap: () => controller.setActiveAccount(account.id),
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
                      controller.closeAccountSelectorView();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddAccountView(
                            factory:
                                controller.bindings.addAccountControllerFactory,
                            inputs: (
                              onAccountAdded:
                                  controller.inputs.onAccountSwitched,
                              canGoBack: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }, debugLabel: 'AccountSelectorView.AccountList'),
          ),
          const Divider(),
          // Account settings
          Watch((context) {
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
                    builder: (_) => AccountSettingsView(
                      factory:
                          controller.bindings.accountSettingsControllerFactory,
                      inputs: (
                        account: controller.inputs.activeAccount.value,
                        onAccountRemoved: controller.inputs.onAccountSwitched,
                      ),
                    ),
                  ),
                );
              },
            );
          }, debugLabel: 'AccountSelectorView.AccountSettings'),
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
