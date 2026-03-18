import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leithmail/domain/entities/account.dart';
import 'package:leithmail/presentation/dashboard/dashboard_controller.dart';
import 'package:leithmail/presentation/dashboard/dashboard_state.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        title: const Text(
          'Accounts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: controller.goToLogin,
          ),
        ],
      ),
      body: Obx(() {
        final s = controller.state.value;
        return switch (s) {
          DashboardStateLoading() => const Center(
            child: CircularProgressIndicator(color: Colors.white38),
          ),
          DashboardStateError(:final message) => Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          DashboardStateLoaded(:final accounts, :final activeAccountId) =>
            accounts.isEmpty
                ? const Center(
                    child: Text(
                      'No accounts',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: accounts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _AccountTile(
                      account: accounts[i],
                      isActive: accounts[i].id == activeAccountId,
                      onTap: () => controller.setActiveAccount(accounts[i].id),
                      onDelete: () => controller.deleteAccount(accounts[i].id),
                    ),
                  ),
        };
      }),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final Account account;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AccountTile({
    required this.account,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: CircleAvatar(
        backgroundColor: isActive ? Colors.white : Colors.white12,
        child: Text(
          account.emailAddress.local[0].toUpperCase(),
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        account.emailAddress.toString(),
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white38),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
