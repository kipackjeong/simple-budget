import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart' as service;
import 'service_providers.dart';

/// State class for transactions with pagination
class TransactionsState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  const TransactionsState({
    required this.transactions,
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 0,
  });

  TransactionsState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Notifier for handling transaction list with pagination
class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final service.TransactionService _service;
  static const int _pageSize = 20;

  TransactionsNotifier(this._service)
      : super(const TransactionsState(transactions: []));

  /// Fetch initial transactions
  Future<void> fetchTransactions({
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final transactions = await _service.getTransactions(
        limit: _pageSize,
        offset: 0,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      );
      
      // Ensure transactions are treated as model Transaction objects
      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
        hasMore: transactions.length >= _pageSize,
        currentPage: 0,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load transactions: ${err.toString()}',
      );
    }
  }

  /// Load more transactions for pagination
  Future<void> loadMore({
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (state.isLoading || !state.hasMore) return;

    try {
      state = state.copyWith(isLoading: true);
      
      final newPage = state.currentPage + 1;
      final offset = newPage * _pageSize;
      
      final newTransactions = await _service.getTransactions(
        limit: _pageSize,
        offset: offset,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (newTransactions.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
        );
        return;
      }
      
      state = state.copyWith(
        transactions: [...state.transactions, ...newTransactions],
        isLoading: false,
        hasMore: newTransactions.length >= _pageSize,
        currentPage: newPage,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load more transactions: ${err.toString()}',
      );
    }
  }

  /// Add a new transaction
  Future<void> addTransaction({
    required String categoryId,
    required double amount,
    required DateTime transactionDate,
    String? description,
    bool isRecurring = false,
    String? recurringItemId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final transaction = await _service.createTransaction(
        categoryId: categoryId,
        amount: amount,
        transactionDate: transactionDate,
        description: description,
        isRecurring: isRecurring,
        recurringItemId: recurringItemId,
      );
      
      state = state.copyWith(
        transactions: [transaction, ...state.transactions],
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create transaction: ${err.toString()}',
      );
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _service.deleteTransaction(id);
      state = state.copyWith(
        transactions: state.transactions.where((t) => t.id != id).toList(),
      );
    } catch (err) {
      state = state.copyWith(
        errorMessage: 'Failed to delete transaction: ${err.toString()}',
      );
    }
  }
}

/// Provider for transactions state notifier
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  final service = ref.watch(transactionServiceProvider);
  return TransactionsNotifier(service);
});

/// Provider for transaction summary (income, expenses, balance)
final transactionSummaryProvider = FutureProvider.family<Map<String, double>, DateRange>((ref, dateRange) async {
  final service = ref.watch(transactionServiceProvider);
  
  try {
    final summary = await service.getTransactionSummary(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
    
    // Calculate balance from income and expense
    final income = summary['income'] ?? 0.0;
    final expense = summary['expense'] ?? 0.0;
    
    return {
      'income': income,
      'expense': expense,
      'balance': income + expense, // expense is negative
    };
  } catch (err) {
    throw Exception('Failed to get transaction summary: ${err.toString()}');
  }
});

/// Simple date range class for providers
class DateRange {
  final DateTime start;
  final DateTime end;
  
  const DateRange({required this.start, required this.end});
}
