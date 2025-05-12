import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';

/// Repository interface for transaction data
abstract class TransactionRepository {
  /// Get all transactions
  Future<List<Transaction>> getTransactions();
  
  /// Get transaction by id
  Future<Transaction?> getTransactionById(String id);
  
  /// Add a new transaction
  Future<Transaction> addTransaction(Transaction transaction);
  
  /// Update an existing transaction
  Future<Transaction> updateTransaction(Transaction transaction);
  
  /// Delete a transaction
  Future<bool> deleteTransaction(String id);
  
  /// Calculate total balance from all transactions
  Future<double> calculateBalance();
  
  /// Calculate total income
  Future<double> calculateTotalIncome();
  
  /// Calculate total expenses
  Future<double> calculateTotalExpenses();
}
