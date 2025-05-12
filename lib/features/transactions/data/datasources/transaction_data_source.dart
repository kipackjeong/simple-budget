import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';

/// Interface for transaction data sources
abstract class TransactionDataSource {
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
}

/// Mock implementation of TransactionDataSource for development
class MockTransactionDataSource implements TransactionDataSource {
  /// In-memory storage for transactions
  final List<Transaction> _transactions = [
    Transaction(
      id: '1',
      title: 'Shopping',
      amount: -84.00,
      date: DateTime(2025, 5, 11),
      category: TransactionCategory.Shopping,
    ),
    Transaction(
      id: '2',
      title: 'Restaurant',
      amount: -32.50,
      date: DateTime(2025, 5, 10),
      category: TransactionCategory.Restaurant,
    ),
    Transaction(
      id: '3',
      title: 'Salary',
      amount: 3500.00,
      date: DateTime(2025, 5, 9),
      category: TransactionCategory.Salary,
    ),
  ];

  @override
  Future<List<Transaction>> getTransactions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions;
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final res =
          _transactions.firstWhere((transaction) => transaction.id == id);
      return res;
    } catch (err) {
      // Return null if transaction not found
      return null;
    }
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    _transactions.add(transaction);
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _transactions.indexWhere((t) => t.id == transaction.id);

    if (index != -1) {
      _transactions[index] = transaction;
      return transaction;
    } else {
      throw Exception('Transaction not found');
    }
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final initialLength = _transactions.length;
    _transactions.removeWhere((transaction) => transaction.id == id);

    return _transactions.length < initialLength;
  }
}
