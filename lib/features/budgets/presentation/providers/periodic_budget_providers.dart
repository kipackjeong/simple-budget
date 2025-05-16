import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/features/budgets/data/datasources/periodic_budget_data_source.dart';
import 'package:spending_tracker/features/budgets/data/repositories/periodic_budget_repository_impl.dart';
import 'package:spending_tracker/features/budgets/domain/repositories/periodic_budget_repository.dart';
import 'package:spending_tracker/features/budgets/domain/entities/periodic_budget.dart';

/// Provider for periodic budget data source
final periodicBudgetDataSourceProvider = Provider<PeriodicBudgetDataSource>(
  (ref) => SupabasePeriodicBudgetDataSource(),
);

/// Provider for periodic budget repository
final periodicBudgetRepositoryProvider = Provider<PeriodicBudgetRepository>(
  (ref) => PeriodicBudgetRepositoryImpl(ref.watch(periodicBudgetDataSourceProvider)),
);

/// Provider for fetching all periodic budgets
final periodicBudgetsProvider = FutureProvider<List<PeriodicBudget>>(
  (ref) async => ref.watch(periodicBudgetRepositoryProvider).getPeriodicBudgets(),
);
