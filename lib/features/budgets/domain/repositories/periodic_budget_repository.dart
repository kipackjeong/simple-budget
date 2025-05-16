import '../entities/periodic_budget.dart';

/// Repository interface for periodic budgets
abstract class PeriodicBudgetRepository {
  /// Fetch all periodic budgets for the current user
  Future<List<PeriodicBudget>> getPeriodicBudgets();

  /// Fetch a specific periodic budget by ID
  Future<PeriodicBudget?> getPeriodicBudgetById(String id);

  /// Add a new periodic budget entry
  Future<void> addPeriodicBudget(PeriodicBudget budget);
}
