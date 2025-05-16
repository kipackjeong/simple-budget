import '../../domain/entities/fixed_expense.dart';
import '../../domain/repositories/fixed_expense_repository.dart';
import '../datasources/fixed_expense_data_source.dart';

/// Implementation of FixedExpenseRepository
class FixedExpenseRepositoryImpl implements FixedExpenseRepository {
  final FixedExpenseDataSource _dataSource;

  /// Constructor
  FixedExpenseRepositoryImpl(this._dataSource);

  @override
  Future<List<FixedExpense>> getFixedExpenses() async {
    try {
      return await _dataSource.getFixedExpenses();
    } catch (err) {
      throw Exception('Failed to get fixed expenses: $err');
    }
  }

  @override
  Future<FixedExpense?> getFixedExpense(String id) async {
    try {
      return await _dataSource.getFixedExpense(id);
    } catch (err) {
      throw Exception('Failed to get fixed expense: $err');
    }
  }

  @override
  Future<void> addFixedExpense(FixedExpense expense) async {
    try {
      await _dataSource.addFixedExpense(expense);
    } catch (err) {
      throw Exception('Failed to add fixed expense: $err');
    }
  }

  @override
  Future<void> updateFixedExpense(FixedExpense expense) async {
    try {
      await _dataSource.updateFixedExpense(expense);
    } catch (err) {
      throw Exception('Failed to update fixed expense: $err');
    }
  }

  @override
  Future<void> deleteFixedExpense(String id) async {
    try {
      await _dataSource.deleteFixedExpense(id);
    } catch (err) {
      throw Exception('Failed to delete fixed expense: $err');
    }
  }

  @override
  Future<double> calculateTotalFixedExpenses() async {
    try {
      final expenses = await getFixedExpenses();

      // Calculate total monthly amount, adjusting for frequency
      double total = 0;
      for (final expense in expenses) {
        switch (expense.frequency.toLowerCase()) {
          case 'monthly':
            total += expense.amount;
            break;
          case 'quarterly':
            total += expense.amount / 3;
            break;
          case 'annual':
            total += expense.amount / 12;
            break;
          default:
            total += expense.amount;
        }
      }

      return total;
    } catch (err) {
      throw Exception('Failed to calculate total fixed expenses: $err');
    }
  }
}
