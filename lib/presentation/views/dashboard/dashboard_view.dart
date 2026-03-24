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
const double _kAccountSelectorPaneWidth = 300;
const double _kMobileBreakpoint = 1000;

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
          Expanded(
            child: Column(
              children: [
                Material(
                  color: colorScheme.surface,
                  child: SizedBox(
                    height: 72,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.search_outlined),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    borderSide: BorderSide(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    borderSide: BorderSide(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 8),
                          Watch((context) {
                            final account =
                                controller.inputs.activeAccount.value;
                            return _AccountChip(
                              email: account.emailAddress,
                              isOpen:
                                  controller.isAccountSelectorPaneOpen.value,
                              onTap: controller.toggleAccountSelectorPane,
                            );
                          }, debugLabel: 'DashboardView._AccountChip'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Material(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            color: colorScheme.surfaceContainerLow,
                            child: Watch((context) {
                              final isEmailSelected =
                                  controller.selectedEmail.value != null;
                              return isEmailSelected
                                  ? EmailReadingPane(controller: controller)
                                  : EmailListPane(controller: controller);
                            }, debugLabel: 'DashboardView.CentralPane'),
                          ),
                        ),
                      ),
                      Watch((context) {
                        final isAccountSelectorOpen =
                            controller.isAccountSelectorPaneOpen.value;
                        return isAccountSelectorOpen
                            ? SizedBox(
                                width: _kAccountSelectorPaneWidth,
                                child: AccountSelectorPane(
                                  controller: controller,
                                  onClose: () =>
                                      controller.closeAccountSelectorPane(),
                                ),
                              )
                            : SizedBox.shrink();
                      }, debugLabel: 'DashboardView.AccountSelectorPane'),
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
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(email.value),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primary,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
