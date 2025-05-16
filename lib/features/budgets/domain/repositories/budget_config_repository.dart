import '../entities/budget_config.dart';

/// Repository interface for budget configuration
abstract class BudgetConfigRepository {
  /// Fetch the budget configuration for the current user
  Future<BudgetConfig?> getBudgetConfig();

  /// Create a new budget configuration
  Future<void> createBudgetConfig(BudgetConfig config);

  /// Update an existing budget configuration
  Future<void> updateBudgetConfig(BudgetConfig config);
}
