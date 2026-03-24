import 'package:flutter/material.dart';
import 'package:leithmail/domain/entities/email_address.dart';
import 'package:leithmail/presentation/base/controller_widget.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller.dart';
import 'package:leithmail/presentation/views/dashboard/parts/account_selector_pane.dart';
import 'package:leithmail/presentation/views/dashboard/parts/email_list_pane.dart';
import 'package:leithmail/presentation/views/dashboard/parts/mailbox_selector_pane.dart';
import 'package:leithmail/presentation/views/dashboard/parts/email_reading_pane.dart';

const double _kSidebarWidth = 300;
const double _kEmailListWidth = 300;
const double _kAccountSelectorPaneWidth = 240;
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
            child: MailboxSelectorPane(controller: controller),
          ),
          VerticalDivider(width: 0.5, color: colorScheme.outlineVariant),
          Expanded(
            child: Column(
              children: [
                _DesktopAppBar(controller: controller),
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
                              controller.isAccountSelectorPaneOpen.value;
                          return Row(
                            children: [
                              Expanded(
                                child: EmailReadingPane(controller: controller),
                              ),
                              if (isOpen) ...[
                                VerticalDivider(
                                  width: 0.5,
                                  color: colorScheme.outlineVariant,
                                ),
                                SizedBox(
                                  width: _kAccountSelectorPaneWidth,
                                  child: AccountSelectorPane(
                                    controller: controller,
                                    onClose: () =>
                                        controller.closeAccountSelectorPane(),
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
  const _DesktopAppBar({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Spacer(),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.refresh_outlined, size: 18),
              onPressed: () => controller.reload(),
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 4),
            Watch((context) {
              final account = controller.inputs.activeAccount.value;
              return _AccountChip(
                email: account.emailAddress,
                isOpen: controller.isAccountSelectorPaneOpen.value,
                onTap: controller.toggleAccountSelectorPane,
              );
            }, debugLabel: 'DashboardView._AccountChip'),
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
          body: EmailReadingPane(controller: controller),
        );
      }

      return Scaffold(
        drawer: Drawer(child: MailboxSelectorPane(controller: controller)),
        endDrawer: Drawer(
          child: Builder(
            builder: (scaffoldContext) => AccountSelectorPane(
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

class _AccountChip extends StatelessWidget {
  const _AccountChip({
    required this.email,
    required this.isOpen,
    required this.onTap,
  });

  final EmailAddress email;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = email.value.substring(0, 2).toUpperCase();

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
            Text(email.value, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
