import '../../domain/entities/budget_config.dart';
import '../../domain/repositories/budget_config_repository.dart';
import '../datasources/budget_config_data_source.dart';

/// Implementation of BudgetConfigRepository using Supabase data source
class BudgetConfigRepositoryImpl implements BudgetConfigRepository {
  final BudgetConfigDataSource dataSource;
  
  BudgetConfigRepositoryImpl(this.dataSource);

  @override
  Future<BudgetConfig?> getBudgetConfig() async {
    try {
      final res = await dataSource.getBudgetConfig();
      return res;
    } catch (err) {
      throw Exception('Failed to get budget configuration: $err');
    }
  }

  @override
  Future<void> createBudgetConfig(BudgetConfig config) async {
    try {
      await dataSource.createBudgetConfig(config);
    } catch (err) {
      throw Exception('Failed to create budget configuration: $err');
    }
  }

  @override
  Future<void> updateBudgetConfig(BudgetConfig config) async {
    try {
      await dataSource.updateBudgetConfig(config);
    } catch (err) {
      throw Exception('Failed to update budget configuration: $err');
    }
  }
}
