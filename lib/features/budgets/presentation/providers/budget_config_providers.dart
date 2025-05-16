import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/features/budgets/data/datasources/budget_config_data_source.dart';
import 'package:spending_tracker/features/budgets/data/repositories/budget_config_repository_impl.dart';
import 'package:spending_tracker/features/budgets/domain/entities/budget_config.dart';
import 'package:spending_tracker/features/budgets/domain/repositories/budget_config_repository.dart';

/// Provider for budget configuration data source
final budgetConfigDataSourceProvider = Provider<BudgetConfigDataSource>(
  (ref) => SupabaseBudgetConfigDataSource(),
);

/// Provider for budget configuration repository
final budgetConfigRepositoryProvider = Provider<BudgetConfigRepository>(
  (ref) => BudgetConfigRepositoryImpl(ref.watch(budgetConfigDataSourceProvider)),
);

/// Provider for fetching budget configuration
final budgetConfigProvider = FutureProvider<BudgetConfig?>(
  (ref) async => ref.watch(budgetConfigRepositoryProvider).getBudgetConfig(),
);

/// Provider for checking if a budget configuration exists
final hasBudgetConfigProvider = FutureProvider<bool>(
  (ref) async {
    final res = await ref.watch(budgetConfigProvider.future);
    return res != null;
  },
);

/// Notifier for managing budget configuration state and operations
class BudgetConfigNotifier extends StateNotifier<AsyncValue<BudgetConfig?>> {
  final BudgetConfigRepository _repository;

  BudgetConfigNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Load initial data
    _loadBudgetConfig();
  }

  Future<void> _loadBudgetConfig() async {
    try {
      state = const AsyncValue.loading();
      final res = await _repository.getBudgetConfig();
      state = AsyncValue.data(res);
    } catch (err) {
      state = AsyncValue.error(err, StackTrace.current);
    }
  }

  Future<void> createBudgetConfig(BudgetConfig config) async {
    try {
      await _repository.createBudgetConfig(config);
      await _loadBudgetConfig();
    } catch (err) {
      state = AsyncValue.error(err, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateBudgetConfig(BudgetConfig config) async {
    try {
      await _repository.updateBudgetConfig(config);
      await _loadBudgetConfig();
    } catch (err) {
      state = AsyncValue.error(err, StackTrace.current);
      rethrow;
    }
  }
}

/// Provider for budget config state notifier
final budgetConfigNotifierProvider = StateNotifierProvider<BudgetConfigNotifier, AsyncValue<BudgetConfig?>>(
  (ref) => BudgetConfigNotifier(ref.watch(budgetConfigRepositoryProvider)),
);
