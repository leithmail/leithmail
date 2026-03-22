import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:leithmail/domain/entities/mock_email.dart';
import 'package:leithmail/presentation/views/dashboard/dashboard_controller.dart';

class EmailListPane extends StatelessWidget {
  const EmailListPane({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Watch((context) {
      final isLoading = controller.isLoadingEmails.value;
      final emails = controller.emails.value;
      final selected = controller.selectedEmail.value;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (emails.isEmpty) {
        return Center(
          child: Text(
            'No messages',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        );
      }

      return ListView.separated(
        itemCount: emails.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          final email = emails[index];
          final isSelected = selected?.id == email.id;
          return _EmailTile(
            email: email,
            isSelected: isSelected,
            onTap: () => controller.selectEmail(email),
          );
        },
      );
    }, debugLabel: 'EmailListPane.root');
  }
}

class _EmailTile extends StatelessWidget {
  const _EmailTile({
    required this.email,
    required this.isSelected,
    required this.onTap,
  });

  final MockEmail email;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 8),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: email.isRead
                      ? Colors.transparent
                      : colorScheme.primary,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          email.sender,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: email.isRead
                                ? FontWeight.normal
                                : FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        email.date,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email.subject,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: email.isRead
                          ? FontWeight.normal
                          : FontWeight.w500,
                      color: email.isRead
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email.preview,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
