import '../entities/fixed_expense.dart';

/// Repository interface for Fixed Expenses
abstract class FixedExpenseRepository {
  /// Get all fixed expenses for the current user
  Future<List<FixedExpense>> getFixedExpenses();
  
  /// Get a specific fixed expense by ID
  Future<FixedExpense?> getFixedExpense(String id);
  
  /// Add a new fixed expense
  Future<void> addFixedExpense(FixedExpense expense);
  
  /// Update an existing fixed expense
  Future<void> updateFixedExpense(FixedExpense expense);
  
  /// Delete a fixed expense
  Future<void> deleteFixedExpense(String id);
  
  /// Calculate the total monthly amount of all fixed expenses
  Future<double> calculateTotalFixedExpenses();
}
