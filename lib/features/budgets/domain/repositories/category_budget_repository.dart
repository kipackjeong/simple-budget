import '../entities/category_budget.dart';

/// Repository interface for managing CategoryBudget entities.
abstract class CategoryBudgetRepository {
  Future<List<CategoryBudget>> getCategoryBudgets(String userId, int year, int month);
  Future<CategoryBudget?> getCategoryBudget(String id);
  Future<void> addCategoryBudget(CategoryBudget budget);
  Future<void> updateCategoryBudget(CategoryBudget budget);
  Future<void> deleteCategoryBudget(String id);
}
