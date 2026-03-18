import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leithmail/presentation/dashboard/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Obx(() {
        final s = controller.state.value;
        return switch (s) {
          DashboardStateLoading() => const Center(
            child: CircularProgressIndicator(color: Colors.white38),
          ),
          DashboardStateLoaded(:final account) => Center(
            child: Text(
              account.emailAddress.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DashboardStateError() => const Center(
            child: Text(
              'Failed to load account',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        };
      }),
    );
  }
}
