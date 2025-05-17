import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recurring_item.dart';
import '../models/period_type.dart';
import '../models/entry_type.dart';
import 'supabase_service.dart';

/// Service for recurring income/expense operations
class RecurringItemService extends SupabaseService {
  static const String _tableName = 'recurring_items';

  RecurringItemService({SupabaseClient? supabaseClient}) : super(supabaseClient: supabaseClient);

  /// Get all recurring items for current user
  Future<List<RecurringItem>> getRecurringItems() async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to fetch recurring items');
    }
    
    try {
      final res = await supabase
          .from(_tableName)
          .select()
          .eq('user_id', currentUserId!)
          .order('name');
      
      return res.map<RecurringItem>((json) => RecurringItem.fromJson(json)).toList();
    } catch (err) {
      _logError('Failed to fetch recurring items', err);
      throw Exception('Failed to load recurring items');
    }
  }

  /// Get recurring items by type (income/expense)
  Future<List<RecurringItem>> getRecurringItemsByType(EntryType type) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to fetch recurring items');
    }
    
    try {
      final res = await supabase
          .from(_tableName)
          .select()
          .eq('user_id', currentUserId!)
          .eq('type', type.toDbString())
          .order('name');
      
      return res.map<RecurringItem>((json) => RecurringItem.fromJson(json)).toList();
    } catch (err) {
      _logError('Failed to fetch recurring items by type', err);
      throw Exception('Failed to load recurring items by type');
    }
  }

  /// Create a new recurring item
  Future<RecurringItem> createRecurringItem({
    required String name,
    required double amount,
    required PeriodType period,
    required EntryType type,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to create recurring item');
    }
    
    try {
      final data = {
        'user_id': currentUserId,
        'name': name,
        'amount': amount,
        'period': period.toDbString(),
        'type': type.toDbString(),
      };
      
      final res = await supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();
      
      return RecurringItem.fromJson(res);
    } catch (err) {
      _logError('Failed to create recurring item', err);
      throw Exception('Failed to create recurring item');
    }
  }

  /// Update a recurring item
  Future<RecurringItem> updateRecurringItem({
    required String id,
    String? name,
    double? amount,
    PeriodType? period,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to update recurring item');
    }
    
    try {
      // Only include fields that need updating
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (amount != null) data['amount'] = amount;
      if (period != null) data['period'] = period.toDbString();
      
      if (data.isEmpty) {
        throw Exception('No fields to update');
      }
      
      final res = await supabase
          .from(_tableName)
          .update(data)
          .eq('id', id)
          .eq('user_id', currentUserId!) // Ensure user owns this item
          .select()
          .single();
      
      return RecurringItem.fromJson(res);
    } catch (err) {
      _logError('Failed to update recurring item', err);
      throw Exception('Failed to update recurring item');
    }
  }

  /// Delete a recurring item
  Future<void> deleteRecurringItem(String id) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to delete recurring item');
    }
    
    try {
      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', currentUserId!); // Ensure user owns this item
    } catch (err) {
      _logError('Failed to delete recurring item', err);
      throw Exception('Failed to delete recurring item');
    }
  }
  
  /// Log errors to console and potentially to a monitoring service
  void _logError(String message, dynamic error) {
    // In a real app, this could use proper logging/monitoring
    // ignore: avoid_print
    print('ERROR: $message - ${error.toString()}');
  }
}
