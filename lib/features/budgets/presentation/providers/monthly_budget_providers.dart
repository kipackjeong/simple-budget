import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/monthly_budget.dart';
import '../../data/repositories/monthly_budget_repository_impl.dart';

/// Provider for the MonthlyBudgetRepositoryImpl
final monthlyBudgetRepositoryProvider =
    Provider<MonthlyBudgetRepositoryImpl>((ref) {
  return MonthlyBudgetRepositoryImpl();
});

/// Async provider for fetching all monthly budgets for the current user
final monthlyBudgetsProvider = FutureProvider<List<MonthlyBudget>>((ref) async {
  final repo = ref.watch(monthlyBudgetRepositoryProvider);
  return await repo.getAllMonthlyBudgets();
});
