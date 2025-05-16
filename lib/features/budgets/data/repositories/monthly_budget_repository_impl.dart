import '../../domain/entities/monthly_budget.dart';
import '../datasources/monthly_budget_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository implementation for MonthlyBudget
class MonthlyBudgetRepositoryImpl {
  final SupabaseMonthlyBudgetDataSource dataSource;

  MonthlyBudgetRepositoryImpl({SupabaseMonthlyBudgetDataSource? dataSource})
      : dataSource = dataSource ?? SupabaseMonthlyBudgetDataSource(Supabase.instance.client);

  /// Fetch all monthly budgets for the current user
  Future<List<MonthlyBudget>> getAllMonthlyBudgets() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('No logged-in user');
      return await dataSource.getMonthlyBudgets(userId);
    } catch (err) {
      // Log error for debugging, but do not expose sensitive info
      print('Error fetching monthly budgets: $err');
      return [];
    }
  }

  /// Add a new monthly budget
  Future<void> addMonthlyBudget(MonthlyBudget budget) async {
    try {
      await dataSource.addMonthlyBudget(budget);
    } catch (err) {
      print('Error adding monthly budget: $err');
      rethrow;
    }
  }
}
