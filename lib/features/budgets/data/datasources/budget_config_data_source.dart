import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/budget_config.dart';

/// Abstract data source for budget configuration
abstract class BudgetConfigDataSource {
  /// Get budget configuration for the current user
  Future<BudgetConfig?> getBudgetConfig();
  
  /// Create a new budget configuration
  Future<void> createBudgetConfig(BudgetConfig config);
  
  /// Update an existing budget configuration
  Future<void> updateBudgetConfig(BudgetConfig config);
}

/// Supabase implementation of BudgetConfigDataSource
class SupabaseBudgetConfigDataSource implements BudgetConfigDataSource {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'budget_configs';

  @override
  Future<BudgetConfig?> getBudgetConfig() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;
      
      final res = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (res == null) return null;
      return BudgetConfig.fromMap(res);
    } catch (err) {
      throw Exception('Failed to get budget configuration: $err');
    }
  }

  @override
  Future<void> createBudgetConfig(BudgetConfig config) async {
    try {
      final data = config.toMap()..remove('id');
      await _client.from(_table).insert(data);
    } catch (err) {
      throw Exception('Failed to create budget configuration: $err');
    }
  }

  @override
  Future<void> updateBudgetConfig(BudgetConfig config) async {
    try {
      final data = config.toMap()..remove('id');
      await _client.from(_table).update(data).eq('id', config.id);
    } catch (err) {
      throw Exception('Failed to update budget configuration: $err');
    }
  }
}
