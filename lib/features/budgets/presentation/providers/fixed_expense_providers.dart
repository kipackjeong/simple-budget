import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/fixed_expense_data_source.dart';
import '../../data/repositories/fixed_expense_repository_impl.dart';
import '../../domain/entities/fixed_expense.dart';
import '../../domain/repositories/fixed_expense_repository.dart';

/// Provider for the fixed expense data source
final fixedExpenseDataSourceProvider = Provider<FixedExpenseDataSource>(
  (ref) => SupabaseFixedExpenseDataSource(Supabase.instance.client),
);

/// Provider for the fixed expense repository
final fixedExpenseRepositoryProvider = Provider<FixedExpenseRepository>(
  (ref) => FixedExpenseRepositoryImpl(ref.watch(fixedExpenseDataSourceProvider)),
);

/// Provider for fetching all fixed expenses
final fixedExpensesProvider = FutureProvider<List<FixedExpense>>(
  (ref) async => ref.watch(fixedExpenseRepositoryProvider).getFixedExpenses(),
);

/// Provider for calculating the total monthly amount of fixed expenses
final totalFixedExpensesProvider = FutureProvider<double>(
  (ref) async => ref.watch(fixedExpenseRepositoryProvider).calculateTotalFixedExpenses(),
);

/// Notifier for managing fixed expense state and operations
class FixedExpenseNotifier extends StateNotifier<AsyncValue<List<FixedExpense>>> {
  final FixedExpenseRepository _repository;

  FixedExpenseNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFixedExpenses();
  }

  /// Load all fixed expenses
  Future<void> loadFixedExpenses() async {
    try {
      state = const AsyncValue.loading();
      final expenses = await _repository.getFixedExpenses();
      state = AsyncValue.data(expenses);
    } catch (err) {
      state = AsyncValue.error(err, StackTrace.current);
    }
  }

  /// Add a new fixed expense
  Future<void> addFixedExpense(FixedExpense expense) async {
    try {
      await _repository.addFixedExpense(expense);
      await loadFixedExpenses();
    } catch (err) {
      throw Exception('Failed to add fixed expense: $err');
    }
  }

  /// Update an existing fixed expense
  Future<void> updateFixedExpense(FixedExpense expense) async {
    try {
      await _repository.updateFixedExpense(expense);
      await loadFixedExpenses();
    } catch (err) {
      throw Exception('Failed to update fixed expense: $err');
    }
  }

  /// Delete a fixed expense
  Future<void> deleteFixedExpense(String id) async {
    try {
      await _repository.deleteFixedExpense(id);
      await loadFixedExpenses();
    } catch (err) {
      throw Exception('Failed to delete fixed expense: $err');
    }
  }
}

/// Provider for fixed expense state notifier
final fixedExpenseNotifierProvider = StateNotifierProvider<FixedExpenseNotifier, AsyncValue<List<FixedExpense>>>(
  (ref) => FixedExpenseNotifier(ref.watch(fixedExpenseRepositoryProvider)),
);
