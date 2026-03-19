import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/domain/entities/mock_mailbox.dart';
import 'package:leithmail/presentation/dashboard/dashboard_controller.dart';

class MailboxSidebar extends StatelessWidget {
  const MailboxSidebar({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Text(
              'leithmail',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ),
          const Divider(),
          // Compose
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Compose'),
              style: FilledButton.styleFrom(alignment: Alignment.centerLeft),
            ),
          ),
          // Mailboxes section label
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Mailboxes',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ),
          // Mailbox list
          Expanded(
            child: Watch((context) {
              final mailboxes = controller.mailboxes.value;
              final selected = controller.selectedMailbox.value;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
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
            }),
          ),
        ],
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

    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
      leading: Icon(
        mailbox.icon,
        size: 18,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        mailbox.name,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      trailing: mailbox.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${mailbox.unreadCount}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
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
