import 'package:flutter/material.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/presentation/account_settings/account_settings_controller.dart';
import 'package:leithmail/presentation/add_account/add_account_controller.dart';
import 'package:leithmail/presentation/dashboard/dashboard_controller.dart';
import 'package:leithmail/presentation/widgets/account_panel.dart';
import 'package:leithmail/presentation/widgets/email_list_pane.dart';
import 'package:leithmail/presentation/widgets/mailbox_sidebar.dart';
import 'package:leithmail/presentation/widgets/reading_pane.dart';

const double _kSidebarWidth = 210;
const double _kEmailListWidth = 300;
const double _kAccountPanelWidth = 240;
const double _kMobileBreakpoint = 600;

class DashboardScreen extends ControllerWidget<DashboardController> {
  const DashboardScreen({
    super.key,
    required super.controller,
    required this.onAccountAdded,
    required this.onAccountRemoved,
    required this.activeAccount,
  });

  final VoidCallback onAccountAdded;
  final VoidCallback onAccountRemoved;

  /// Reactive signal so the screen always reflects the current active account
  /// without needing a full rebuild from the parent.
  final ReadonlySignal<Account?> activeAccount;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < _kMobileBreakpoint;

    return isMobile
        ? _MobileLayout(
            controller: controller,
            addAccountController: controller.addAccountControllerFactory
                .create(),
            accountSettingsController: controller
                .accountSettingsControllerFactory
                .create(),
            activeAccount: activeAccount,
            onAccountAdded: onAccountAdded,
            onAccountRemoved: onAccountRemoved,
          )
        : _DesktopLayout(
            controller: controller,
            addAccountController: controller.addAccountControllerFactory
                .create(),
            accountSettingsController: controller
                .accountSettingsControllerFactory
                .create(),
            activeAccount: activeAccount,
            onAccountAdded: onAccountAdded,
            onAccountRemoved: onAccountRemoved,
          );
  }
}

// ---------------------------------------------------------------------------
// Desktop layout
// ---------------------------------------------------------------------------

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: _kSidebarWidth,
            child: MailboxSidebar(controller: controller),
          ),
          VerticalDivider(width: 0.5, color: colorScheme.outlineVariant),
          Expanded(
            child: Column(
              children: [
                _DesktopAppBar(
                  controller: controller,
                  activeAccount: activeAccount,
                ),
                const Divider(),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: _kEmailListWidth,
                        child: EmailListPane(controller: controller),
                      ),
                      VerticalDivider(
                        width: 0.5,
                        color: colorScheme.outlineVariant,
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final isOpen = controller.isAccountPanelOpen.watch(
                              context,
                            );
                            return Row(
                              children: [
                                Expanded(
                                  child: ReadingPane(controller: controller),
                                ),
                                if (isOpen) ...[
                                  VerticalDivider(
                                    width: 0.5,
                                    color: colorScheme.outlineVariant,
                                  ),
                                  SizedBox(
                                    width: _kAccountPanelWidth,
                                    child: AccountPanel(
                                      controller: controller,
                                      addAccountController:
                                          addAccountController,
                                      accountSettingsController:
                                          accountSettingsController,
                                      activeAccount: activeAccount,
                                      onAccountAdded: onAccountAdded,
                                      onAccountRemoved: onAccountRemoved,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopAppBar extends StatelessWidget {
  const _DesktopAppBar({required this.controller, required this.activeAccount});

  final DashboardController controller;
  final ReadonlySignal<Account?> activeAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Watch((context) {
              final mailbox = controller.selectedMailbox.value;
              return Text(
                mailbox?.name ?? '',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              );
            }, debugLabel: 'DashboardScreen.SelectedMailboxTitle'),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Icon(
                      Icons.search,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Search mail...',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.refresh_outlined, size: 18),
              onPressed: () => controller.reload(),
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 4),
            Watch((context) {
              final account = activeAccount.value;
              return _AccountChip(
                activeAccount: account,
                isOpen: controller.isAccountPanelOpen.value,
                onTap: controller.toggleAccountPanel,
              );
            }, debugLabel: 'DashboardScreen.AccountChip'),
          ],
        ),
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({
    required this.activeAccount,
    required this.isOpen,
    required this.onTap,
  });

  final Account? activeAccount;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final email = activeAccount?.emailAddress.value ?? '';
    final initials = email.isNotEmpty
        ? email.substring(0, 2).toUpperCase()
        : '?';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isOpen ? colorScheme.primary : colorScheme.outlineVariant,
            width: isOpen ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: colorScheme.primary,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(email, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile layout
// ---------------------------------------------------------------------------

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
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
    return Watch((context) {
      final selectedEmail = controller.selectedEmail.value;
      final account = activeAccount.value;

      if (selectedEmail != null) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: controller.clearSelectedEmail),
            title: Watch(
              (ctx) => Text(
                controller.selectedMailbox.value?.name ?? '',
                style: const TextStyle(fontSize: 15),
              ),
              debugLabel: 'DashboardScreen.SelectedMailboxTitle',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, size: 18),
                onPressed: () {},
              ),
            ],
          ),
          body: ReadingPane(controller: controller),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Watch(
            (ctx) => Text(
              controller.selectedMailbox.value?.name ?? 'leithmail',
              style: const TextStyle(fontSize: 15),
            ),
            debugLabel: 'DashboardScreen.SelectedMailboxTitle',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_outlined, size: 18),
              onPressed: () {},
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => SizedBox(
                      height: 400,
                      child: AccountPanel(
                        controller: controller,
                        addAccountController: addAccountController,
                        accountSettingsController: accountSettingsController,
                        activeAccount: activeAccount,
                        onAccountAdded: onAccountAdded,
                        onAccountRemoved: onAccountRemoved,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    account?.emailAddress.value.substring(0, 2).toUpperCase() ??
                        '?',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(child: MailboxSidebar(controller: controller)),
        body: EmailListPane(controller: controller),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.edit_outlined),
        ),
      );
    }, debugLabel: 'DashboardScreen.MobileLayout');
  }
}
