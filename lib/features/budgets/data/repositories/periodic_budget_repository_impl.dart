import 'package:spending_tracker/features/budgets/data/datasources/periodic_budget_data_source.dart';
import 'package:spending_tracker/features/budgets/domain/repositories/periodic_budget_repository.dart';
import 'package:spending_tracker/features/budgets/domain/entities/periodic_budget.dart';

/// Implementation of PeriodicBudgetRepository using Supabase data source
class PeriodicBudgetRepositoryImpl implements PeriodicBudgetRepository {
  final PeriodicBudgetDataSource dataSource;
  
  PeriodicBudgetRepositoryImpl(this.dataSource);

  @override
  Future<List<PeriodicBudget>> getPeriodicBudgets() async {
    try {
      final res = await dataSource.getPeriodicBudgets();
      return res;
    } catch (err) {
      throw Exception('Failed to get periodic budgets: $err');
    }
  }

  @override
  Future<PeriodicBudget?> getPeriodicBudgetById(String id) async {
    try {
      final res = await dataSource.getPeriodicBudgetById(id);
      return res;
    } catch (err) {
      throw Exception('Failed to get periodic budget by id: $err');
    }
  }

  @override
  Future<void> addPeriodicBudget(PeriodicBudget budget) async {
    try {
      await dataSource.addPeriodicBudget(budget);
    } catch (err) {
      throw Exception('Failed to add periodic budget: $err');
    }
  }
}
