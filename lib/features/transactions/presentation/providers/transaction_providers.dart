import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/features/transactions/data/datasources/transaction_data_source.dart';
import 'package:spending_tracker/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:spending_tracker/features/transactions/data/repositories/supabase_transaction_repository.dart';
import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:spending_tracker/features/transactions/domain/repositories/transaction_repository.dart';

/// Provider for transaction data source
final transactionDataSourceProvider = Provider<TransactionDataSource>(
  (ref) => MockTransactionDataSource(),
);

/// Provider for transaction repository
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) {
    final dataSource = ref.watch(transactionDataSourceProvider);
    return TransactionRepositoryImpl(dataSource);
  },
);

/// Provider for all transactions (from Supabase)
final transactionsProvider = FutureProvider<List<Transaction>>(
  (ref) async {
    return await SupabaseTransactionRepository().fetchTransactions();
  },
);

/// Provider for the total account balance
final balanceProvider = FutureProvider<double>(
  (ref) {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.calculateBalance();
  },
);

/// Provider for the total income
final totalIncomeProvider = FutureProvider<double>(
  (ref) {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.calculateTotalIncome();
  },
);

/// Provider for the total expenses
final totalExpensesProvider = FutureProvider<double>(
  (ref) {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.calculateTotalExpenses();
  },
);

/// Provider for a specific transaction by id
final transactionByIdProvider = FutureProvider.family<Transaction?, String>(
  (ref, id) {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.getTransactionById(id);
  },
);
