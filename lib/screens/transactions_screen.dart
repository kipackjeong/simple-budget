import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_providers.dart';
import '../providers/category_providers.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/error_indicator.dart';
import '../widgets/loading_indicator.dart';

/// Screen for viewing and managing transactions
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  // Date range for filtering
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Set default date range to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;

    // Initialize data
    _loadData();

    // Set up scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  /// Load initial transaction data
  Future<void> _loadData() async {
    await ref.read(categoriesProvider.notifier).fetchCategories();
    await ref.read(transactionsProvider.notifier).fetchTransactions(
          startDate: _startDate,
          endDate: _endDate,
          categoryId: _selectedCategoryId,
        );
  }

  /// Scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(transactionsProvider);
      if (!state.isLoading && state.hasMore) {
        ref.read(transactionsProvider.notifier).loadMore(
              startDate: _startDate,
              endDate: _endDate,
              categoryId: _selectedCategoryId,
            );
      }
    }
  }

  /// Show date range picker and filter transactions
  Future<void> _showDateRangePicker() async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      end: _endDate ?? DateTime.now(),
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });

      // Reload transactions with new date range
      await ref.read(transactionsProvider.notifier).fetchTransactions(
            startDate: _startDate,
            endDate: _endDate,
            categoryId: _selectedCategoryId,
          );
    }
  }

  /// Show category filter dialog
  Future<void> _showCategoryFilterDialog() async {
    final categoriesState = ref.read(categoriesProvider);

    final selectedCategoryId = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Category'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('All Categories'),
                  selected: _selectedCategoryId == null,
                  onTap: () => Navigator.pop(context, null),
                ),
                ...categoriesState.categories.map((category) {
                  return ListTile(
                    title: Text(category.name),
                    selected: _selectedCategoryId == category.id,
                    onTap: () => Navigator.pop(context, category.id),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );

    if (selectedCategoryId != _selectedCategoryId) {
      setState(() {
        _selectedCategoryId = selectedCategoryId;
      });

      // Reload transactions with new category filter
      await ref.read(transactionsProvider.notifier).fetchTransactions(
            startDate: _startDate,
            endDate: _endDate,
            categoryId: _selectedCategoryId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch states from providers
    final transactionsState = ref.watch(transactionsProvider);
    final categoriesState = ref.watch(categoriesProvider);

    // Return just the content without a Scaffold since HomeScreen already provides one
    return Column(
      children: [
        // Active filters display
        if (_startDate != null && _endDate != null) _buildActiveFiltersBar(),

        // Search field
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
            ),
            onChanged: (value) {
              // Local search implementation
              // (server-side search would be better for large datasets)
              if (value.trim().isEmpty) {
                _loadData();
              }
              // Implement search logic
            },
          ),
        ),

        // Transaction list
        Expanded(
          child: _buildTransactionsList(transactionsState),
        ),
      ],
    );
  }

  Widget _buildActiveFiltersBar() {
    final DateFormat dateFormat = DateFormat('MMM d, y');
    final String dateRangeText =
        '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}';

    // Get category name if a category filter is active
    String? categoryName;
    if (_selectedCategoryId != null) {
      final categoriesState = ref.read(categoriesProvider);
      final selectedCategory = categoriesState.categories.firstWhere(
          (c) => c.id == _selectedCategoryId,
          orElse: () => null as dynamic);
      categoryName = selectedCategory?.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8.0,
              children: [
                // Date range chip
                Chip(
                  label:
                      Text(dateRangeText, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      // Reset to current month
                      final now = DateTime.now();
                      _startDate = DateTime(now.year, now.month, 1);
                      _endDate = now;
                    });
                    _loadData();
                  },
                ),

                // Category filter chip (if active)
                if (categoryName != null)
                  Chip(
                    label: Text(categoryName,
                        style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                      _loadData();
                    },
                  ),
              ],
            ),
          ),

          // Clear all filters button
          if (_selectedCategoryId != null)
            TextButton(
              onPressed: () {
                setState(() {
                  // Reset to current month
                  final now = DateTime.now();
                  _startDate = DateTime(now.year, now.month, 1);
                  _endDate = now;
                  _selectedCategoryId = null;
                });
                _loadData();
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(TransactionsState state) {
    // If loading initial data
    if (state.isLoading && state.transactions.isEmpty) {
      return const LoadingIndicator(message: 'Loading transactions...');
    }

    // If there's an error
    if (state.errorMessage != null && state.transactions.isEmpty) {
      return ErrorIndicator(
        message: state.errorMessage!,
        onRetry: _loadData,
      );
    }

    // Empty state
    if (state.transactions.isEmpty) {
      return _buildEmptyState();
    }

    // Transaction list with pagination
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom when loading more items
          if (index == state.transactions.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Regular transaction item
          final transaction = state.transactions[index];
          return TransactionListItem(
            transaction: transaction,
            onTap: () {
              // Navigate to transaction details
            },
            onLongPress: () {
              // Show options menu
            },
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
            Icons.receipt_long,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions found',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (_selectedCategoryId != null ||
              _startDate !=
                  DateTime(DateTime.now().year, DateTime.now().month, 1))
            const Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to add transaction screen
            },
            child: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }
}
