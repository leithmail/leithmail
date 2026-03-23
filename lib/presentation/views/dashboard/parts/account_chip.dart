import 'package:flutter/material.dart';
import 'package:leithmail/domain/entities/email_address.dart';

class AccountChip extends StatelessWidget {
  const AccountChip({
    super.key,
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
