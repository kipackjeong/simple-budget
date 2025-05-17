import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import 'supabase_service.dart';

/// Service for category-related operations
class CategoryService extends SupabaseService {
  static const String _tableName = 'categories';

  CategoryService({SupabaseClient? supabaseClient}) : super(supabaseClient: supabaseClient);

  /// Get all categories for current user
  Future<List<Category>> getCategories() async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to fetch categories');
    }
    
    try {
      final res = await supabase
          .from(_tableName)
          .select()
          .eq('user_id', currentUserId!)
          .order('name');
      
      return res.map<Category>((json) => Category.fromJson(json)).toList();
    } catch (err) {
      throw Exception('Failed to fetch categories: ${err.toString()}');
    }
  }

  /// Create a new category
  Future<Category> createCategory(String name) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to create category');
    }
    
    try {
      final data = {
        'user_id': currentUserId,
        'name': name,
      };
      
      final res = await supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();
      
      return Category.fromJson(res);
    } catch (err) {
      throw Exception('Failed to create category: ${err.toString()}');
    }
  }

  /// Update a category
  Future<Category> updateCategory(String id, String name) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to update category');
    }
    
    try {
      final data = {
        'name': name,
      };
      
      final res = await supabase
          .from(_tableName)
          .update(data)
          .eq('id', id)
          .eq('user_id', currentUserId!) // Ensure user owns this category
          .select()
          .single();
      
      return Category.fromJson(res);
    } catch (err) {
      throw Exception('Failed to update category: ${err.toString()}');
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to delete category');
    }
    
    try {
      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', currentUserId!); // Ensure user owns this category
    } catch (err) {
      throw Exception('Failed to delete category: ${err.toString()}');
    }
  }
}
