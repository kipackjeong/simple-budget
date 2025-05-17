import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recurring_item.dart';
import '../models/entry_type.dart';
import '../models/period_type.dart';
import '../services/recurring_item_service.dart';
import 'service_providers.dart';

/// State class for recurring items
class RecurringItemsState {
  final List<RecurringItem> items;
  final bool isLoading;
  final String? errorMessage;

  const RecurringItemsState({
    required this.items,
    this.isLoading = false,
    this.errorMessage,
  });

  RecurringItemsState copyWith({
    List<RecurringItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RecurringItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for handling recurring items
class RecurringItemsNotifier extends StateNotifier<RecurringItemsState> {
  final RecurringItemService _service;

  RecurringItemsNotifier(this._service)
      : super(const RecurringItemsState(items: []));

  /// Fetch all recurring items
  Future<void> fetchRecurringItems() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final items = await _service.getRecurringItems();
      
      state = state.copyWith(
        items: items,
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load recurring items: ${err.toString()}',
      );
    }
  }

  /// Fetch recurring items by type (income/expense)
  Future<void> fetchRecurringItemsByType(EntryType type) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final items = await _service.getRecurringItemsByType(type);
      
      state = state.copyWith(
        items: items,
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load recurring items: ${err.toString()}',
      );
    }
  }

  /// Create a new recurring item
  Future<void> createRecurringItem({
    required String name,
    required double amount,
    required EntryType type,
    required PeriodType period,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final newItem = await _service.createRecurringItem(
        name: name,
        amount: amount,
        type: type,
        period: period,
      );
      
      state = state.copyWith(
        items: [...state.items, newItem],
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create recurring item: ${err.toString()}',
      );
    }
  }

  /// Update a recurring item
  Future<void> updateRecurringItem({
    required String id,
    String? name,
    double? amount,
    PeriodType? period,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final updatedItem = await _service.updateRecurringItem(
        id: id,
        name: name,
        amount: amount,
        period: period,
      );
      
      state = state.copyWith(
        items: state.items.map((item) => 
          item.id == id ? updatedItem : item).toList(),
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update recurring item: ${err.toString()}',
      );
    }
  }

  /// Delete a recurring item
  Future<void> deleteRecurringItem(String id) async {
    try {
      await _service.deleteRecurringItem(id);
      
      state = state.copyWith(
        items: state.items.where((item) => item.id != id).toList(),
      );
    } catch (err) {
      state = state.copyWith(
        errorMessage: 'Failed to delete recurring item: ${err.toString()}',
      );
    }
  }
}

/// Provider for recurring items state notifier
final recurringItemsProvider = StateNotifierProvider<RecurringItemsNotifier, RecurringItemsState>((ref) {
  final service = ref.watch(recurringItemServiceProvider);
  return RecurringItemsNotifier(service);
});

/// Provider for income recurring items
final incomeRecurringItemsProvider = Provider<List<RecurringItem>>((ref) {
  final state = ref.watch(recurringItemsProvider);
  return state.items.where((item) => item.type == EntryType.income).toList();
});

/// Provider for expense recurring items
final expenseRecurringItemsProvider = Provider<List<RecurringItem>>((ref) {
  final state = ref.watch(recurringItemsProvider);
  return state.items.where((item) => item.type == EntryType.expense).toList();
});
