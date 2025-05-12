import 'package:spending_tracker/features/transactions/data/datasources/transaction_data_source.dart';
import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:spending_tracker/features/transactions/domain/repositories/transaction_repository.dart';

/// Implementation of the transaction repository
class TransactionRepositoryImpl implements TransactionRepository {
  /// Data source for transactions
  final TransactionDataSource dataSource;

  /// Creates a transaction repository implementation
  TransactionRepositoryImpl(this.dataSource);

  @override
  Future<List<Transaction>> getTransactions() async {
    try {
      final res = await dataSource.getTransactions();
      return res;
    } catch (err) {
      throw Exception('Failed to get transactions: $err');
    }
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      final res = await dataSource.getTransactionById(id);
      return res;
    } catch (err) {
      throw Exception('Failed to get transaction by id: $err');
    }
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    try {
      final res = await dataSource.addTransaction(transaction);
      return res;
    } catch (err) {
      throw Exception('Failed to add transaction: $err');
    }
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      final res = await dataSource.updateTransaction(transaction);
      return res;
    } catch (err) {
      throw Exception('Failed to update transaction: $err');
    }
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    try {
      final res = await dataSource.deleteTransaction(id);
      return res;
    } catch (err) {
      throw Exception('Failed to delete transaction: $err');
    }
  }

  @override
  Future<double> calculateBalance() async {
    try {
      final transactions = await dataSource.getTransactions();
      final res = transactions.fold(
          0.0, (sum, transaction) => sum + transaction.amount);
      return res;
    } catch (err) {
      throw Exception('Failed to calculate balance: $err');
    }
  }

  @override
  Future<double> calculateTotalIncome() async {
    try {
      final transactions = await dataSource.getTransactions();
      final res = transactions
          .where((transaction) => transaction.amount > 0)
          .fold(0.0, (sum, transaction) => sum + transaction.amount);
      return res;
    } catch (err) {
      throw Exception('Failed to calculate total income: $err');
    }
  }

  @override
  Future<double> calculateTotalExpenses() async {
    try {
      final transactions = await dataSource.getTransactions();
      final res = transactions
          .where((transaction) => transaction.amount < 0)
          .fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
      return res;
    } catch (err) {
      throw Exception('Failed to calculate total expenses: $err');
    }
  }
}
