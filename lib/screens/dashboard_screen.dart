import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add import for HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spending_tracker/models/entry_type.dart';
import '../providers/transaction_providers.dart';
import '../providers/budget_providers.dart';
import '../providers/recurring_item_providers.dart';
import '../providers/user_providers.dart';
import '../models/period_type.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/error_indicator.dart';
import '../widgets/loading_indicator.dart';

/// The main dashboard screen showing budget summary, recent transactions,
/// and other key financial information
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  PeriodType _selectedPeriodType = PeriodType.monthly;
  final DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Load initial data
    Future.microtask(() {
      // Load transactions
      ref.read(transactionsProvider.notifier).fetchTransactions(
            startDate: _getStartDate(_selectedPeriodType),
            endDate: _now,
          );

      // Load budget data
      ref.read(budgetProvider.notifier).fetchBudget(
            periodType: _selectedPeriodType,
          );

      // Load recurring items
      ref.read(recurringItemsProvider.notifier).fetchRecurringItems();
    });
  }

  /// Get the start date based on period type
  DateTime _getStartDate(PeriodType periodType) {
    if (periodType == PeriodType.weekly) {
      // Start of current week (Monday)
      return DateTime(_now.year, _now.month, _now.day - _now.weekday + 1);
    } else {
      // Start of current month
      return DateTime(_now.year, _now.month, 1);
    }
  }
  
  /// Change the period type with animations and data reload
  void _changePeriodType(PeriodType newType) {
    // Add haptic feedback for better UX
    HapticFeedback.selectionClick();
    
    if (newType != _selectedPeriodType) {
      setState(() {
        _selectedPeriodType = newType;
      });

      // Reload data with new period type
      ref.read(transactionsProvider.notifier).fetchTransactions(
        startDate: _getStartDate(_selectedPeriodType),
        endDate: _now,
      );
      ref.read(budgetProvider.notifier).fetchBudget(
        periodType: _selectedPeriodType,
      );
    }
  }
  
  /// Build a custom period selection button with TikTok-inspired animations
  Widget _buildPeriodButton(BuildContext context, String label, PeriodType type, {required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedPeriodType == type;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onSecondary : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch states from providers
    final userState = ref.watch(userProvider);
    final transactionsState = ref.watch(transactionsProvider);
    final budgetState = ref.watch(budgetProvider);
    final recurringItemsState = ref.watch(recurringItemsProvider);

    // Watch transaction summary for current period
    final transactionSummary = ref.watch(
      transactionSummaryProvider(
        DateRange(
          start: _getStartDate(_selectedPeriodType),
          end: _now,
        ),
      ),
    );

    // Return just the content without a Scaffold since HomeScreen already provides one
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh all data
        await ref.read(transactionsProvider.notifier).fetchTransactions(
              startDate: _getStartDate(_selectedPeriodType),
              endDate: _now,
            );
        await ref.read(budgetProvider.notifier).fetchBudget(
              periodType: _selectedPeriodType,
            );
      },
      child: _buildDashboardContent(
        context,
        userState,
        transactionsState,
        budgetState,
        transactionSummary,
        recurringItemsState,
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    UserState userState,
    TransactionsState transactionsState,
    BudgetState budgetState,
    AsyncValue<Map<String, double>> transactionSummary,
    RecurringItemsState recurringItemsState,
  ) {
    // Show loading indicator if any data is still loading
    if (userState.isLoading ||
        transactionsState.isLoading ||
        budgetState.isLoading ||
        transactionSummary is AsyncLoading ||
        recurringItemsState.isLoading) {
      return const LoadingIndicator();
    }

    // Show error if any
    if (userState.errorMessage != null ||
        transactionsState.errorMessage != null ||
        budgetState.errorMessage != null ||
        transactionSummary is AsyncError ||
        recurringItemsState.errorMessage != null) {
      return ErrorIndicator(
        message: userState.errorMessage ??
            transactionsState.errorMessage ??
            budgetState.errorMessage ??
            recurringItemsState.errorMessage ??
            'An error occurred loading dashboard data',
        onRetry: () {
          ref.read(transactionsProvider.notifier).fetchTransactions(
                startDate: _getStartDate(_selectedPeriodType),
                endDate: _now,
              );
          ref.read(budgetProvider.notifier).fetchBudget(
                periodType: _selectedPeriodType,
              );
          ref.read(recurringItemsProvider.notifier).fetchRecurringItems();
        },
      );
    }

    // If we have data, show the dashboard
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Format user email for display
    String userEmail = userState.user?.email ?? 'there';
    String userName = userEmail.split('@').first;
    // Capitalize first letter of name
    userName = userName.isNotEmpty 
        ? '${userName[0].toUpperCase()}${userName.substring(1)}' 
        : 'there';
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Add bouncy scroll physics for better UX
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User greeting section with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                // User avatar with gradient background
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.secondary,
                        colorScheme.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Greeting text with animations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${userName}!',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your financial snapshot',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Period selector with TikTok-style buttons
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Time Period',
                    style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                  ),
                ),
                // Custom period selector with TikTok-style animations
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      // Weekly button
                      _buildPeriodButton(
                        context, 
                        'Weekly', 
                        PeriodType.weekly,
                        onTap: () => _changePeriodType(PeriodType.weekly),
                      ),
                      const SizedBox(width: 4),
                      // Monthly button
                      _buildPeriodButton(
                        context, 
                        'Monthly', 
                        PeriodType.monthly,
                        onTap: () => _changePeriodType(PeriodType.monthly),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Budget summary card
          BudgetSummaryCard(
            periodType: _selectedPeriodType,
            budgetData: budgetState.periodBudget,
            transactionSummary: transactionSummary,
          ),
          const SizedBox(height: 24),

          // Recent transactions
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          if (transactionsState.transactions.isEmpty)
            _buildEmptyTransactionsState()
          else
            _buildTransactionsList(transactionsState),

          const SizedBox(height: 24),

          // Upcoming recurring items
          Text(
            'Upcoming Payments',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          if (recurringItemsState.items.isEmpty)
            const Text('No upcoming recurring items')
          else
            _buildUpcomingRecurringItemsList(recurringItemsState),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactionsState() {
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
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
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

  Widget _buildTransactionsList(TransactionsState state) {
    // Show only the first 5 transactions
    final displayedTransactions = state.transactions.take(5).toList();

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedTransactions.length,
          itemBuilder: (context, index) {
            final transaction = displayedTransactions[index];
            return TransactionListItem(
              transaction: transaction,
              onTap: () {
                // Navigate to transaction details
              },
            );
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // Navigate to transactions screen
          },
          child: const Text('View All Transactions'),
        ),
      ],
    );
  }

  Widget _buildUpcomingRecurringItemsList(RecurringItemsState state) {
    // Show only upcoming expense items (first 3)
    final upcomingItems = state.items
        .where((item) => item.type == EntryType.expense)
        .take(3)
        .toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingItems.length,
      itemBuilder: (context, index) {
        final item = upcomingItems[index];
        return ListTile(
          leading: const Icon(Icons.event_repeat),
          title: Text(item.name),
          subtitle: Text('${item.period.toString()} • Next: Unknown'),
          trailing: Text(
            currencyFormat.format(item.amount),
            style: TextStyle(
              color: item.amount < 0
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
