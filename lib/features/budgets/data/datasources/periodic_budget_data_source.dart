import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spending_tracker/features/budgets/domain/entities/periodic_budget.dart';

/// Abstract data source for periodic budgets
abstract class PeriodicBudgetDataSource {
  Future<List<PeriodicBudget>> getPeriodicBudgets();
  Future<PeriodicBudget?> getPeriodicBudgetById(String id);
  Future<void> addPeriodicBudget(PeriodicBudget budget);
}

/// Supabase implementation of PeriodicBudgetDataSource
class SupabasePeriodicBudgetDataSource implements PeriodicBudgetDataSource {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'budgets';

  @override
  Future<List<PeriodicBudget>> getPeriodicBudgets() async {
    final res = await _client
        .from(_table)
        .select()
        .order('inserted_at', ascending: false);
    return (res as List<dynamic>)
        .map((e) => PeriodicBudget.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PeriodicBudget?> getPeriodicBudgetById(String id) async {
    try {
      final res = await _client.from(_table).select().eq('id', id).single();
      return PeriodicBudget.fromMap(res);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addPeriodicBudget(PeriodicBudget budget) async {
    final data = budget.toMap()..remove('id');
    await _client.from(_table).insert(data);
  }
}
