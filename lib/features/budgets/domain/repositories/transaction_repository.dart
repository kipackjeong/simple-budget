import '../entities/transaction.dart';

/// Repository interface for managing Transaction entities.
abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions(String userId, {DateTime? start, DateTime? end});
  Future<Transaction?> getTransaction(String id);
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
}
