import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/period_type.dart';
import '../services/budget_service.dart';
import 'service_providers.dart';

/// State class for budget data
class BudgetState {
  final Map<String, dynamic>? periodBudget;
  final List<Map<String, dynamic>> categoryBudgets;
  final bool isLoading;
  final String? errorMessage;
  final PeriodType periodType;
  final DateTime periodStart;
  final DateTime periodEnd;

  const BudgetState({
    this.periodBudget,
    required this.categoryBudgets,
    this.isLoading = false,
    this.errorMessage,
    this.periodType = PeriodType.monthly,
    required this.periodStart,
    required this.periodEnd,
  });

  BudgetState copyWith({
    Map<String, dynamic>? periodBudget,
    List<Map<String, dynamic>>? categoryBudgets,
    bool? isLoading,
    String? errorMessage,
    PeriodType? periodType,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return BudgetState(
      periodBudget: periodBudget ?? this.periodBudget,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      periodType: periodType ?? this.periodType,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }
}

/// Notifier for handling budget data
class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetService _service;

  BudgetNotifier(this._service)
      : super(BudgetState(
          categoryBudgets: [],
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
        )) {
    // Initialize with current period bounds
    final now = DateTime.now();
    final bounds = _service.getCurrentPeriodBounds(PeriodType.monthly, now);
    state = state.copyWith(
      periodStart: bounds['start'],
      periodEnd: bounds['end'],
    );
  }

  /// Fetch budget data for the current period type
  Future<void> fetchBudget({PeriodType? periodType}) async {
    final type = periodType ?? state.periodType;
    final bounds = _service.getCurrentPeriodBounds(type);
    
    try {
      state = state.copyWith(
        isLoading: true, 
        errorMessage: null,
        periodType: type,
        periodStart: bounds['start'],
        periodEnd: bounds['end'],
      );
      
      // Get period budget
      final periodBudget = await _service.getPeriodBudget(
        periodType: type,
        periodStart: bounds['start']!,
      );
      
      // Get category budgets
      final categoryBudgets = await _service.getCategoryBudgets(
        periodType: type,
        periodStart: bounds['start']!,
      );
      
      state = state.copyWith(
        periodBudget: periodBudget,
        categoryBudgets: categoryBudgets,
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load budget data: ${err.toString()}',
      );
    }
  }

  /// Update a category budget amount
  Future<void> updateCategoryBudget(String categoryBudgetId, double amount) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final updatedBudget = await _service.updateCategoryBudget(
        categoryBudgetId: categoryBudgetId,
        amount: amount,
      );
      
      // Update the specific category budget in the list
      final updatedList = state.categoryBudgets.map((budget) {
        if (budget['id'] == categoryBudgetId) {
          return updatedBudget;
        }
        return budget;
      }).toList();
      
      state = state.copyWith(
        categoryBudgets: updatedList,
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update category budget: ${err.toString()}',
      );
    }
  }

  /// Get budget progress summary
  Future<Map<String, dynamic>> getBudgetProgress() async {
    try {
      return await _service.getBudgetProgress(state.periodType);
    } catch (err) {
      throw Exception('Failed to get budget progress: ${err.toString()}');
    }
  }

  /// Change the period type (monthly, weekly, etc.)
  void changePeriodType(PeriodType type) {
    if (type == state.periodType) return;
    fetchBudget(periodType: type);
  }
}

/// Provider for budget state notifier
final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  final service = ref.watch(budgetServiceProvider);
  return BudgetNotifier(service);
});

/// Provider for budget progress data
final budgetProgressProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final budgetNotifier = ref.watch(budgetProvider.notifier);
  return budgetNotifier.getBudgetProgress();
});
