import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';

/// Repository for interacting with Supabase transactions table
class SupabaseTransactionRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'transactions';

  /// Fetches all transactions from Supabase
  /// Fetches all transactions from Supabase
  Future<List<Transaction>> fetchTransactions() async {
    try {
      final List<dynamic> response = await _client
          .from(_table)
          .select()
          .order('date', ascending: false);
      return response
          .map((json) => Transaction.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (err) {
      throw Exception('Failed to fetch transactions: $err');
    }
  }

  /// Adds a new transaction to Supabase
  /// Adds a new transaction to Supabase
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final data = transaction.toMap();
      // Remove id if null or empty string to let Supabase generate it
      if (data['id'] == null || data['id'] == '') data.remove('id');
      await _client.from(_table).insert(data);
    } on PostgrestException catch (err) {
      throw Exception('Supabase insert error: ${err.message}');
    } catch (err) {
      throw Exception('Failed to add transaction: $err');
    }
  }
}
