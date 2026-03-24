import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/domain/entities/mock_mailbox.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller.dart';

class MailboxSelectorPane extends StatelessWidget {
  const MailboxSelectorPane({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compose Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mail_outline, size: 20),
                label: const Text('Compose'),
                style: FilledButton.styleFrom(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Mailboxes section label
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                'Mailboxes',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // Mailbox list
            Expanded(
              child: Watch((context) {
                final mailboxes = controller.mailboxes.value;
                final selected = controller.selectedMailbox.value;
                return ListView.separated(
                  separatorBuilder: (_, _) => const SizedBox(height: 2),
                  itemCount: mailboxes.length,
                  itemBuilder: (context, index) {
                    final mailbox = mailboxes[index];
                    final isSelected = selected?.id == mailbox.id;
                    return _MailboxTile(
                      mailbox: mailbox,
                      isSelected: isSelected,
                      onTap: () => controller.selectMailbox(mailbox),
                    );
                  },
                );
              }, debugLabel: 'MailboxSelectorPane.MailboxList'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MailboxTile extends StatelessWidget {
  const _MailboxTile({
    required this.mailbox,
    required this.isSelected,
    required this.onTap,
  });

  final MockMailbox mailbox;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return ListTile(
      selectedTileColor: colorScheme.secondaryContainer,
      selectedColor: colorScheme.onSecondaryContainer,
      dense: true,
      selected: isSelected,
      leading: Icon(mailbox.icon, size: 16),
      title: Text(mailbox.name),
      trailing: mailbox.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${mailbox.unreadCount}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
