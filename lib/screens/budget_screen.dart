import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/period_type.dart';
import '../providers/budget_providers.dart';
import '../providers/category_providers.dart';
import '../providers/transaction_providers.dart';
import '../widgets/error_indicator.dart';
import '../widgets/loading_indicator.dart';

/// Screen for viewing and managing budget information
class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PeriodType _currentPeriodType = PeriodType.monthly;
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load initial data
    Future.microtask(() {
      ref.read(budgetProvider.notifier).fetchBudget(
            periodType: _currentPeriodType,
          );
      ref.read(categoriesProvider.notifier).fetchCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Change period type and reload data
  void _changePeriodType(PeriodType newType) {
    if (newType != _currentPeriodType) {
      setState(() {
        _currentPeriodType = newType;
      });

      ref.read(budgetProvider.notifier).fetchBudget(
            periodType: _currentPeriodType,
          );
    }
  }

  /// Edit a category budget amount
  Future<void> _editCategoryBudget(
      String categoryBudgetId, double currentAmount) async {
    final TextEditingController controller = TextEditingController(
      text: currentAmount.toString(),
    );

    final newAmountStr = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Budget Amount'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '\$',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (newAmountStr != null && newAmountStr.isNotEmpty) {
      try {
        final newAmount = double.parse(newAmountStr);
        if (newAmount != currentAmount) {
          await ref.read(budgetProvider.notifier).updateCategoryBudget(
                categoryBudgetId,
                newAmount,
              );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid amount: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetProvider);
    final categoriesState = ref.watch(categoriesProvider);

    // Return just the content without a Scaffold since HomeScreen already provides one
    return _buildContent(budgetState, categoriesState);
  }

  Widget _buildContent(
      BudgetState budgetState, CategoriesState categoriesState) {
    // Show loading indicator
    if (budgetState.isLoading || categoriesState.isLoading) {
      return const LoadingIndicator();
    }

    // Show error if any
    if (budgetState.errorMessage != null ||
        categoriesState.errorMessage != null) {
      return ErrorIndicator(
        message: budgetState.errorMessage ??
            categoriesState.errorMessage ??
            'An error occurred',
        onRetry: () {
          ref.read(budgetProvider.notifier).fetchBudget(
                periodType: _currentPeriodType,
              );
          ref.read(categoriesProvider.notifier).fetchCategories();
        },
      );
    }

    // No budget created yet
    if (budgetState.periodBudget == null &&
        budgetState.categoryBudgets.isEmpty) {
      return _buildNoBudgetState();
    }

    // Show tab view with budget data
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(budgetState),
        _buildCategoriesTab(budgetState, categoriesState),
      ],
    );
  }

  Widget _buildNoBudgetState() {
    final String periodText =
        _currentPeriodType == PeriodType.weekly ? 'weekly' : 'monthly';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No $periodText budget set',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a budget to track your spending',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateBudgetDialog,
            icon: const Icon(Icons.add),
            label: Text('Create $periodText Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BudgetState budgetState) {
    final periodBudget = budgetState.periodBudget;
    final String periodText =
        _currentPeriodType == PeriodType.weekly ? 'Weekly' : 'Monthly';
    final double totalBudgeted = periodBudget != null
        ? double.parse(periodBudget['budgeted_amount'].toString())
        : 0.0;

    // Get date format for period start/end display
    final DateFormat dateFormat = DateFormat('MMM d, y');
    final String periodStartText = dateFormat.format(budgetState.periodStart);
    final String periodEndText = dateFormat.format(budgetState.periodEnd);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget period header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '$periodText Budget',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('$periodStartText - $periodEndText'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total Budgeted: ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        currencyFormat.format(totalBudgeted),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Budget progress
          Text(
            'Budget Progress',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildBudgetProgressChart(budgetState),
          const SizedBox(height: 24),

          // Category breakdown
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildCategoryBreakdown(budgetState),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(
      BudgetState budgetState, CategoriesState categoriesState) {
    final categoryBudgets = budgetState.categoryBudgets;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: categoryBudgets.length,
      itemBuilder: (context, index) {
        final budget = categoryBudgets[index];
        final categoryId = budget['category_id'] as String;
        final amount = double.parse(budget['amount'].toString());
        final spent = double.parse(budget['spent']?.toString() ?? '0.0');
        final progress = amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;

        // Find category name
        final category = categoriesState.categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () =>
              null as dynamic, // This is a workaround for the null check
        );
        final categoryName = category?.name ?? 'Unknown Category';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _editCategoryBudget(budget['id'] as String, amount),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spent: ${currencyFormat.format(spent)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Budget: ${currencyFormat.format(amount)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetProgressChart(BudgetState budgetState) {
    // In a real app, use a proper chart library like fl_chart or charts_flutter
    // This is a simple placeholder
    double totalBudget = 0.0;
    double totalSpent = 0.0;

    for (final budget in budgetState.categoryBudgets) {
      totalBudget += double.parse(budget['amount'].toString());
      totalSpent += double.parse(budget['spent']?.toString() ?? '0.0');
    }

    final progress =
        totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Spent',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  currencyFormat.format(totalSpent),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 16,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% used',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${currencyFormat.format(totalBudget - totalSpent)} remaining',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(BudgetState budgetState) {
    if (budgetState.categoryBudgets.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No category budgets defined'),
          ),
        ),
      );
    }

    return Column(
      children: budgetState.categoryBudgets.map((budget) {
        final amount = double.parse(budget['amount'].toString());
        final spent = double.parse(budget['spent']?.toString() ?? '0.0');
        final progress = amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
        final categoryName = budget['category_name'] as String? ?? 'Unknown';

        return ListTile(
          title: Text(categoryName),
          subtitle: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(spent),
                style: TextStyle(
                  color: progress > 0.9 ? Colors.red : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'of ${currencyFormat.format(amount)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Show dialog to create a new budget
  Future<void> _showCreateBudgetDialog() async {
    final TextEditingController amountController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create ${_currentPeriodType == PeriodType.weekly ? 'Weekly' : 'Monthly'} Budget',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Total Budget Amount',
                prefixText: '\$',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CREATE'),
          ),
        ],
      ),
    );

    if (confirmed == true && amountController.text.isNotEmpty) {
      try {
        final amount = double.parse(amountController.text);
        // Create budget logic would go here
        // This would typically call a service method
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget created')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid amount: $e')),
        );
      }
    }
  }

  /// Show dialog to edit an existing budget
  Future<void> _showEditBudgetDialog(BudgetState budgetState) async {
    final periodBudget = budgetState.periodBudget;
    if (periodBudget == null) return;

    final TextEditingController amountController = TextEditingController(
      text: periodBudget['budgeted_amount'].toString(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit ${_currentPeriodType == PeriodType.weekly ? 'Weekly' : 'Monthly'} Budget',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Total Budget Amount',
                prefixText: '\$',
              ),
              autofocus: true,
            ),
          ],
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

    if (confirmed == true && amountController.text.isNotEmpty) {
      try {
        final amount = double.parse(amountController.text);
        // Update budget logic would go here
        // This would typically call a service method
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid amount: $e')),
        );
      }
    }
  }
}
