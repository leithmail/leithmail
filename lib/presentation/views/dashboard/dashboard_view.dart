import 'package:flutter/material.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
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

class DashboardView extends ControllerWidget<DashboardController> {
  const DashboardView({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
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
                  activeAccount: controller.activeAccount,
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
                            final isOpen = controller.isAccountSelectorViewOpen
                                .watch(context);
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
                                    child: AccountSelectorView(
                                      controller: controller,
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
            }, debugLabel: 'DashboardView.SelectedMailboxTitle'),
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
  const _MobileLayout({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final selectedEmail = controller.selectedEmail.value;
      final account = controller.activeAccount.value;

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
        appBar: AppBar(
          title: Watch(
            (ctx) => Text(
              controller.selectedMailbox.value?.name ?? 'leithmail',
              style: const TextStyle(fontSize: 15),
            ),
            debugLabel: 'DashboardView.SelectedMailboxTitle',
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
                      child: AccountSelectorView(controller: controller),
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
    }, debugLabel: 'DashboardView.MobileLayout');
  }
}
