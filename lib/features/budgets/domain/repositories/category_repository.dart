import '../entities/category.dart';

/// Repository interface for managing Category entities.
abstract class CategoryRepository {
  Future<List<Category>> getCategories(String userId);
  Future<Category?> getCategory(String id);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}
