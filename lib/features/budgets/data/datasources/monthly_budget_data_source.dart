import '../../domain/entities/monthly_budget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for MonthlyBudget using Supabase.
class SupabaseMonthlyBudgetDataSource {
  final SupabaseClient _client;
  final String _table = 'monthly_budgets';

  SupabaseMonthlyBudgetDataSource(this._client);

  Future<List<MonthlyBudget>> getMonthlyBudgets(String userId) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('year', ascending: false)
        .order('month', ascending: false);
    return (res as List<dynamic>)
        .map((e) => MonthlyBudget.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<MonthlyBudget?> getMonthlyBudget(
      String userId, int year, int month) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('year', year)
        .eq('month', month)
        .maybeSingle();
    if (res == null) return null;
    return MonthlyBudget.fromMap(res);
  }

  Future<void> addMonthlyBudget(MonthlyBudget budget) async {
    final data = budget.toMap()..remove('id');
    // Notes is already included if present
    await _client.from(_table).insert(data);
  }

  Future<void> updateMonthlyBudget(MonthlyBudget budget) async {
    final data = budget.toMap()..remove('id');
    await _client.from(_table).update(data).eq('id', budget.id);
  }

  Future<void> deleteMonthlyBudget(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
