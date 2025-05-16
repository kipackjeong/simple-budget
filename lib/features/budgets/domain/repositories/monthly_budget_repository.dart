import '../entities/monthly_budget.dart';

/// Repository interface for managing MonthlyBudget entities.
abstract class MonthlyBudgetRepository {
  Future<List<MonthlyBudget>> getMonthlyBudgets(String userId);
  Future<MonthlyBudget?> getMonthlyBudget(String userId, int year, int month);
  Future<void> addMonthlyBudget(MonthlyBudget budget);
  Future<void> updateMonthlyBudget(MonthlyBudget budget);
  Future<void> deleteMonthlyBudget(String id);
}
