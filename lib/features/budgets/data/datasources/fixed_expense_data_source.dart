import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/fixed_expense.dart';

/// Abstract data source for fixed expenses
abstract class FixedExpenseDataSource {
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
}

/// Supabase implementation of FixedExpenseDataSource
class SupabaseFixedExpenseDataSource implements FixedExpenseDataSource {
  final SupabaseClient _client;
  final String _table = 'fixed_expenses';

  SupabaseFixedExpenseDataSource(this._client);

  @override
  Future<List<FixedExpense>> getFixedExpenses() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];
      
      final res = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('title');
      
      return (res as List<dynamic>)
          .map((e) => FixedExpense.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (err) {
      throw Exception('Failed to get fixed expenses: $err');
    }
  }

  @override
  Future<FixedExpense?> getFixedExpense(String id) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;
      
      final res = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('id', id)
          .maybeSingle();
      
      if (res == null) return null;
      return FixedExpense.fromMap(res);
    } catch (err) {
      throw Exception('Failed to get fixed expense: $err');
    }
  }

  @override
  Future<void> addFixedExpense(FixedExpense expense) async {
    try {
      final data = expense.toMap()..remove('id');
      await _client.from(_table).insert(data);
    } catch (err) {
      throw Exception('Failed to add fixed expense: $err');
    }
  }

  @override
  Future<void> updateFixedExpense(FixedExpense expense) async {
    try {
      final data = expense.toMap()..remove('id');
      await _client.from(_table).update(data).eq('id', expense.id);
    } catch (err) {
      throw Exception('Failed to update fixed expense: $err');
    }
  }

  @override
  Future<void> deleteFixedExpense(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (err) {
      throw Exception('Failed to delete fixed expense: $err');
    }
  }
}
