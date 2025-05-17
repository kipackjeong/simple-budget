import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import 'service_providers.dart';

/// State class for categories
class CategoriesState {
  final List<Category> categories;
  final bool isLoading;
  final String? errorMessage;

  const CategoriesState({
    required this.categories,
    this.isLoading = false,
    this.errorMessage,
  });

  CategoriesState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for handling categories
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final CategoryService _service;

  CategoriesNotifier(this._service)
      : super(const CategoriesState(categories: []));

  /// Fetch all categories
  Future<void> fetchCategories() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final categories = await _service.getCategories();

      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load categories: ${err.toString()}',
      );
    }
  }

  /// Add a new category
  Future<void> addCategory(String name) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final category = await _service.createCategory(name);

      state = state.copyWith(
        categories: [...state.categories, category],
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create category: ${err.toString()}',
      );
    }
  }

  /// Update a category
  Future<void> updateCategory(String id, String name) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final updatedCategory = await _service.updateCategory(id, name);

      state = state.copyWith(
        categories: state.categories
            .map((c) => c.id == id ? updatedCategory : c)
            .toList(),
        isLoading: false,
      );
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update category: ${err.toString()}',
      );
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    try {
      await _service.deleteCategory(id);

      state = state.copyWith(
        categories: state.categories.where((c) => c.id != id).toList(),
      );
    } catch (err) {
      state = state.copyWith(
        errorMessage: 'Failed to delete category: ${err.toString()}',
      );
    }
  }
}

/// Provider for categories state notifier
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  final service = ref.watch(categoryServiceProvider);
  return CategoriesNotifier(service);
});
