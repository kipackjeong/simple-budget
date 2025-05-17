import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_providers.dart';
import '../models/category.dart';
import '../widgets/error_indicator.dart';
import '../widgets/loading_indicator.dart';

/// Screen for managing categories for transactions and budgets
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load categories data
    Future.microtask(() {
      ref.read(categoriesProvider.notifier).fetchCategories();
    });
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  /// Show dialog to create a new category
  Future<void> _showAddCategoryDialog() async {
    _categoryNameController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: _categoryNameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g., Groceries, Rent, Entertainment',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ADD'),
          ),
        ],
      ),
    );

    if (confirmed == true && _categoryNameController.text.trim().isNotEmpty) {
      try {
        await ref.read(categoriesProvider.notifier).addCategory(
              _categoryNameController.text.trim(),
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added')),
          );
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to add category: ${err.toString()}')),
          );
        }
      }
    }
  }

  /// Show dialog to edit a category
  Future<void> _showEditCategoryDialog(Category category) async {
    _categoryNameController.text = category.name;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: _categoryNameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (confirmed == true && _categoryNameController.text.trim().isNotEmpty) {
      try {
        await ref.read(categoriesProvider.notifier).updateCategory(
              category.id,
              _categoryNameController.text.trim(),
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category updated')),
          );
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update category: ${err.toString()}')),
          );
        }
      }
    }
  }

  /// Show confirmation dialog to delete a category
  Future<void> _confirmDeleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          'This will not delete associated transactions, but they will be marked as uncategorized.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(categoriesProvider.notifier).deleteCategory(category.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted')),
          );
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete category: ${err.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);

    // Return just the content without a Scaffold since HomeScreen already provides one
    return _buildContent(categoriesState);
  }

  Widget _buildContent(CategoriesState state) {
    // Show loading indicator
    if (state.isLoading && state.categories.isEmpty) {
      return const LoadingIndicator(message: 'Loading categories...');
    }

    // Show error if any
    if (state.errorMessage != null && state.categories.isEmpty) {
      return ErrorIndicator(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(categoriesProvider.notifier).fetchCategories();
        },
      );
    }

    // Empty state
    if (state.categories.isEmpty) {
      return _buildEmptyState();
    }

    // Categories list with reordering capability
    return RefreshIndicator(
      onRefresh: () => ref.read(categoriesProvider.notifier).fetchCategories(),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.categories.length,
        onReorder: (oldIndex, newIndex) {
          // In a real app, this would persist the new order to the backend
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          setState(() {
            // This is only for UI visualization as we're not persisting order yet
            // You'd need to add order fields to the Category model and backend
          });
        },
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return Dismissible(
            key: Key(category.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16.0),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (_) async {
              await _confirmDeleteCategory(category);
              return false; // We handle deletion ourselves
            },
            direction: DismissDirection.endToStart,
            child: Card(
              key: ValueKey(category.id),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: const Icon(Icons.category),
                title: Text(category.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () => _showEditCategoryDialog(category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDeleteCategory(category),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ],
                ),
                onTap: () => _showEditCategoryDialog(category),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No categories yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add categories to organize your transactions',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
        ],
      ),
    );
  }
}
