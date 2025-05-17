import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import 'supabase_service.dart';

/// Service for transaction-related operations
class TransactionService extends SupabaseService {
  static const String _tableName = 'transactions';

  TransactionService({SupabaseClient? supabaseClient}) : super(supabaseClient: supabaseClient);

  /// Get transactions for the current user with pagination
  Future<List<Transaction>> getTransactions({
    int limit = 20,
    int offset = 0,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to fetch transactions');
    }
    
    try {
      // Start the basic query
      var query = supabase
          .from(_tableName)
          .select('*, categories(*)') // Join with categories
          .eq('user_id', currentUserId!); // Ensure user owns these transactions
      
      // Add optional filters manually
      if (categoryId != null) {
        // Filter by category
        query = query.eq('category_id', categoryId);
      }
      
      // Add date range filters
      if (startDate != null) {
        final startDateStr = startDate.toIso8601String().split('T')[0];
        // Greater than or equal to start date
        query = query.gte('transaction_date', startDateStr);
      }
      
      if (endDate != null) {
        final endDateStr = endDate.toIso8601String().split('T')[0];
        // Less than or equal to end date
        query = query.lte('transaction_date', endDateStr);
      }
      
      // Add sorting and pagination
      final res = await query
          .order('transaction_date', ascending: false)
          .range(offset, offset + limit - 1);
          // No need for limit when using range
      
      return res.map<Transaction>((json) => Transaction.fromJson(json)).toList();
    } catch (err) {
      _logError('Failed to fetch transactions', err);
      throw Exception('Failed to load transactions');
    }
  }

  /// Create a new transaction
  Future<Transaction> createTransaction({
    required String categoryId,
    required double amount,
    required DateTime transactionDate,
    String? description,
    bool isRecurring = false,
    String? recurringItemId,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to create transaction');
    }
    
    try {
      final data = {
        'user_id': currentUserId,
        'category_id': categoryId,
        'amount': amount,
        'transaction_date': transactionDate.toIso8601String().split('T')[0],
        'description': description ?? '',
        'is_recurring': isRecurring,
        if (recurringItemId != null) 'recurring_item_id': recurringItemId,
      };
      
      final res = await supabase
          .from(_tableName)
          .insert(data)
          .select('*, categories(*)')
          .single();
      
      // Call the onTransaction edge function (if applicable)
      try {
        await client.functions.invoke('onTransaction', body: res);
      } catch (fnErr) {
        // Log but don't stop the transaction from being returned
        _logError('Edge function onTransaction failed', fnErr);
      }
      
      return Transaction.fromJson(res);
    } catch (err) {
      _logError('Failed to create transaction', err);
      throw Exception('Failed to create transaction');
    }
  }

  /// Update a transaction
  Future<Transaction> updateTransaction({
    required String id,
    String? categoryId,
    double? amount,
    DateTime? transactionDate,
    String? description,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to update transaction');
    }
    
    try {
      // Only include fields that need updating
      final data = <String, dynamic>{};
      if (categoryId != null) data['category_id'] = categoryId;
      if (amount != null) data['amount'] = amount;
      if (transactionDate != null) data['transaction_date'] = transactionDate.toIso8601String().split('T')[0];
      if (description != null) data['description'] = description;
      
      if (data.isEmpty) {
        throw Exception('No fields to update');
      }
      
      final res = await supabase
          .from(_tableName)
          .update(data)
          .eq('id', id)
          .eq('user_id', currentUserId!) // Ensure user owns this transaction
          .select('*, categories(*)')
          .single();
      
      return Transaction.fromJson(res);
    } catch (err) {
      _logError('Failed to update transaction', err);
      throw Exception('Failed to update transaction');
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to delete transaction');
    }
    
    try {
      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', currentUserId!); // Ensure user owns this transaction
    } catch (err) {
      _logError('Failed to delete transaction', err);
      throw Exception('Failed to delete transaction');
    }
  }
  
  /// Get transaction summary (total income/expense) for a period
  Future<Map<String, double>> getTransactionSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to get transaction summary');
    }
    
    try {
      final res = await client.rpc(
        'sum_transactions_in_period',
        params: {
          'uid': currentUserId,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      );
      
      return {
        'income': (res['income_sum'] ?? 0).toDouble(),
        'expense': (res['expense_sum'] ?? 0).toDouble(),
      };
    } catch (err) {
      _logError('Failed to get transaction summary', err);
      throw Exception('Failed to calculate transaction summary');
    }
  }
  
  /// Log errors to console and potentially to a monitoring service
  void _logError(String message, dynamic error) {
    // In a real app, this could use proper logging/monitoring
    // ignore: avoid_print
    print('ERROR: $message - ${error.toString()}');
  }
}

