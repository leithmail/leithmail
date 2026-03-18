import 'package:leithmail/domain/entities/account.dart';

sealed class DashboardState {}

class DashboardStateLoading extends DashboardState {}

class DashboardStateLoaded extends DashboardState {
  final List<Account> accounts;
  final AccountId? activeAccountId;

  DashboardStateLoaded({required this.accounts, required this.activeAccountId});
}

class DashboardStateError extends DashboardState {
  final String message;
  DashboardStateError(this.message);
}
