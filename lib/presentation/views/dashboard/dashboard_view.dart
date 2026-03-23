import 'package:flutter/material.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
import 'package:leithmail/presentation/views/account_settings/account_settings_view.dart';
import 'package:leithmail/presentation/views/add_account/add_account_view.dart';
import 'package:leithmail/presentation/views/dashboard/parts/account_chip.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller.dart';
import 'package:leithmail/presentation/views/dashboard/parts/account_selector_view.dart';
import 'package:leithmail/presentation/views/dashboard/parts/email_list_pane.dart';
import 'package:leithmail/presentation/views/dashboard/parts/mailbox_sidebar.dart';
import 'package:leithmail/presentation/views/dashboard/parts/reading_pane.dart';

const double _kSidebarWidth = 210;
const double _kEmailListWidth = 300;
const double _kAccountSelectorViewWidth = 240;
const double _kMobileBreakpoint = 600;

class DashboardView
    extends
        ControllerWidget<
          DashboardController,
          DashboardControllerBindings,
          DashboardControllerInputs
        > {
  const DashboardView({
    super.key,
    required super.factory,
    required super.inputs,
  });

  @override
  Widget build(BuildContext context, DashboardController controller) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < _kMobileBreakpoint;

    return isMobile
        ? _MobileLayout(controller: controller)
        : _DesktopLayout(controller: controller);
  }
}

// ---------------------------------------------------------------------------
// Desktop layout
// ---------------------------------------------------------------------------

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.controller});

  final DashboardController controller;

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
                  activeAccount: controller.inputs.activeAccount,
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
                        child: Watch((context) {
                          final isOpen =
                              controller.isAccountSelectorViewOpen.value;
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
                                  width: _kAccountSelectorViewWidth,
                                  child: Builder(
                                    builder: (scaffoldContext) =>
                                        _buildAccountSelectorView(
                                          context: context,
                                          controller: controller,
                                          onClose: controller
                                              .closeAccountSelectorView,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }, debugLabel: 'DashboardView.AccountSelectorPane'),
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
  final ReadonlySignal<Account> activeAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            }, debugLabel: 'DashboardView.SelectedMailboxTitle'),
            const SizedBox(width: 16),
            const Spacer(),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.refresh_outlined, size: 18),
              onPressed: () => controller.reload(),
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 4),
            Watch((context) {
              final account = activeAccount.value;
              return AccountChip(
                email: account.emailAddress,
                isOpen: controller.isAccountSelectorViewOpen.value,
                onTap: controller.toggleAccountSelectorView,
              );
            }, debugLabel: 'DashboardView.AccountChip'),
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
  const _MobileLayout({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final selectedEmail = controller.selectedEmail.value;
      final account = controller.inputs.activeAccount.value;

      if (selectedEmail != null) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: controller.clearSelectedEmail),
            title: Watch(
              (ctx) => Text(
                controller.selectedMailbox.value?.name ?? '',
                style: const TextStyle(fontSize: 15),
              ),
              debugLabel: 'DashboardView.SelectedMailboxTitle',
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
        drawer: Drawer(child: MailboxSidebar(controller: controller)),
        endDrawer: Drawer(
          child: Builder(
            builder: (scaffoldContext) => _buildAccountSelectorView(
              context: context,
              controller: controller,
              onClose: () => Scaffold.of(scaffoldContext).closeEndDrawer(),
            ),
          ),
        ),
        appBar: AppBar(
          title: Watch(
            (ctx) => Text(
              controller.selectedMailbox.value?.name ?? 'leithmail',
              style: const TextStyle(fontSize: 15),
            ),
            debugLabel: 'DashboardView.SelectedMailboxTitle',
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Builder(
                builder: (scaffoldContext) => GestureDetector(
                  onTap: () => Scaffold.of(scaffoldContext).openEndDrawer(),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      account.emailAddress.value.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: EmailListPane(controller: controller),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.edit_outlined),
        ),
      );
    }, debugLabel: 'DashboardView.MobileLayout');
  }
}

AccountSelectorView _buildAccountSelectorView({
  required BuildContext context,
  required DashboardController controller,
  required void Function() onClose,
}) {
  return AccountSelectorView(
    accountSummariesList: controller.inputs.accountSummariesList.value,
    currentAccountId: controller.inputs.activeAccount.value.id,
    onClose: () => onClose(),
    onSelectAccount: (id) {
      onClose();
      controller.setActiveAccount(id);
    },
    onOpenAccountSettings: () {
      onClose();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AccountSettingsView(
            factory: controller.bindings.accountSettingsControllerFactory,
            inputs: (
              account: controller.inputs.activeAccount.value,
              onAccountRemoved: () {
                Navigator.of(context).pop();
                controller.inputs.onAccountSwitched();
              },
            ),
          ),
        ),
      );
    },
    onAddAccount: () {
      onClose();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddAccountView(
            factory: controller.bindings.addAccountControllerFactory,
            inputs: (
              onAccountAdded: () {
                Navigator.of(context).pop();
                controller.inputs.onAccountSwitched();
              },
              canGoBack: true,
            ),
          ),
        ),
      );
    },
  );
}
