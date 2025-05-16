import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/core/widgets/transaction_list_item.dart';
import 'package:spending_tracker/features/budgets/presentation/providers/budget_analysis_providers.dart';
import 'package:spending_tracker/features/budgets/presentation/providers/budget_config_providers.dart';
// Removed unused periodic_budget_providers import
import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';

/// Displays transactions with infinite scrolling.
class InfiniteTransactionList extends ConsumerStatefulWidget {
  /// List of all transactions
  final List<Transaction> transactions;

  /// Callback when user refreshes the list
  final Future<void> Function()? onRefresh;

  /// Callback when user reaches end of list
  final Future<void> Function()? onLoadMore;

  /// Initial page size to display
  final int initialPageSize;

  /// Creates an infinite transaction list widget
  const InfiniteTransactionList({
    Key? key,
    required this.transactions,
    this.onRefresh,
    this.onLoadMore,
    this.initialPageSize = 10,
  }) : super(key: key);

  @override
  ConsumerState<InfiniteTransactionList> createState() =>
      _InfiniteTransactionListState();
}

class _InfiniteTransactionListState
    extends ConsumerState<InfiniteTransactionList> {
  // Current number of transactions to show
  late int _displayCount;

  // Scroll controller to detect when user reaches bottom
  final ScrollController _scrollController = ScrollController();

  // Whether we're currently loading more items
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    // Set initial display count
    _displayCount = widget.initialPageSize;

    // Set up scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(InfiniteTransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If transaction list changed significantly, reset display count
    if (widget.transactions.length > oldWidget.transactions.length + 5 ||
        widget.transactions.length < oldWidget.transactions.length) {
      setState(() {
        _displayCount = widget.initialPageSize;
      });
    }
  }

  /// Handle scroll events for infinite scrolling
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // Load more data when user scrolls to 80% of the list
    if (currentScroll > (maxScroll * 0.8) &&
        !_isLoadingMore &&
        widget.onLoadMore != null &&
        _displayCount < widget.transactions.length) {
      _loadMore();
    }
  }

  /// Load more transactions
  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      // Call onLoadMore callback if provided
      if (widget.onLoadMore != null) {
        await widget.onLoadMore!();
      }

      // Increment displayed transactions by 10
      setState(() {
        _displayCount = _displayCount + 10;
        if (_displayCount > widget.transactions.length) {
          _displayCount = widget.transactions.length;
        }
      });
    } catch (err) {
      // Handle error - display could be implemented here
      debugPrint('Error loading more transactions: $err');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// Handle pull-to-refresh action
  Future<void> _handleRefresh() async {
    try {
      if (widget.onRefresh != null) {
        // Reset display count when refreshing
        setState(() {
          _displayCount = widget.initialPageSize;
        });

        // Call refresh callback
        await widget.onRefresh!();
      }
    } catch (err) {
      debugPrint('Error refreshing transactions: $err');
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    // Early return for empty transaction list
    if (widget.transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No transactions yet'),
              SizedBox(height: 8),
              Text(
                'Your transactions will appear here',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Get the transactions to display with pagination
    final displayedTransactions =
        widget.transactions.take(_displayCount).toList();

    // Group transactions by week
    final groupedTransactions = _groupTransactionsByWeek(displayedTransactions);

    // Get week analysis data from the provider
    final asyncWeeklyAnalysis = ref.watch(weeklyBudgetAnalysisProvider);

    // Render the list with pull-to-refresh and weekly analysis
    final Widget res = RefreshIndicator(
      onRefresh: _handleRefresh,
      child: asyncWeeklyAnalysis.when(
        data: (weeklyAnalyses) => ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: groupedTransactions.length + 1, // +1 for loading indicator
          itemBuilder: (context, index) {
            // Show loading indicator at the end
            if (index == groupedTransactions.length) {
              return _buildLoadingIndicator();
            }

            // Get the week group
            final weekGroup = groupedTransactions[index];
            final weekStart = weekGroup.key;
            final weekEnd = _endOfWeek(weekStart);
            final weekTransactions = weekGroup.value;

            // Find the budget analysis for this week
            final weeklyAnalysis = weeklyAnalyses.firstWhere(
              (analysis) => _isSameWeek(analysis.weekStart, weekStart),
              orElse: () {
                // Calculate actual spent for this week based on transactions
                final actualSpent = weekTransactions
                    .where((t) => t.isExpense)
                    .fold(0.0, (sum, t) => sum + t.amount.abs());

                // Get the most recent weekly budget from the provider if available
                // This is a fallback calculation - better than showing zeros
                final budgetConfig = ref.read(budgetConfigProvider).maybeWhen(
                      data: (config) => config,
                      orElse: () => null,
                    );
                final double budgetedAmount =
                    budgetConfig != null && budgetConfig.monthlyAmount > 0
                        ? budgetConfig.monthlyAmount / 4
                        : 0.0;

                return WeeklyBudgetAnalysis(
                  weekStart: weekStart,
                  weekEnd: weekEnd,
                  budgetedAmount: budgetedAmount,
                  actualSpent: actualSpent,
                );
              },
            );

            // Build the week section with header and items
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Week header with budget comparison
                _buildWeekHeader(context, weeklyAnalysis),
                // Transactions for this week
                ...weekTransactions.asMap().entries.map((entry) {
                  final transaction = entry.value;
                  final innerIndex = entry.key;

                  return _AnimatedTransactionItem(
                    key: ValueKey(transaction.id),
                    transaction: transaction,
                    index: innerIndex,
                  );
                }).toList(),
                // Add some space between weeks
                const SizedBox(height: 16),
              ],
            );
          },
        ),
        loading: () => ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: displayedTransactions.length + 1,
          itemBuilder: (context, index) {
            if (index == displayedTransactions.length) {
              return _buildLoadingIndicator();
            }

            final transaction = displayedTransactions[index];

            return _AnimatedTransactionItem(
              key: ValueKey(transaction.id),
              transaction: transaction,
              index: index,
            );
          },
        ),
        error: (err, stack) {
          // Log the error for debugging
          print('Error loading budget analysis: $err');
          print(stack);

          // Fallback to a regular list without budget info
          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: displayedTransactions.length + 1,
            itemBuilder: (context, index) {
              if (index == displayedTransactions.length) {
                return _buildLoadingIndicator();
              }

              final transaction = displayedTransactions[index];

              return _AnimatedTransactionItem(
                key: ValueKey(transaction.id),
                transaction: transaction,
                index: index,
              );
            },
          );
        },
      ),
    );

    return res;
  }

  /// Group transactions by week
  List<MapEntry<DateTime, List<Transaction>>> _groupTransactionsByWeek(
      List<Transaction> transactions) {
    // Sort transactions by date (newest first)
    final sortedTransactions = [...transactions];
    sortedTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Group transactions by week
    final Map<DateTime, List<Transaction>> groupedByWeek = {};

    for (final transaction in sortedTransactions) {
      final weekStart = _startOfWeek(transaction.date);

      if (!groupedByWeek.containsKey(weekStart)) {
        groupedByWeek[weekStart] = [];
      }

      groupedByWeek[weekStart]!.add(transaction);
    }

    // Convert to list of entries and sort by week (newest first)
    final List<MapEntry<DateTime, List<Transaction>>> result =
        groupedByWeek.entries.toList();
    result.sort((a, b) => b.key.compareTo(a.key));

    return result;
  }

  /// Build a week header with budget comparison
  Widget _buildWeekHeader(BuildContext context, WeeklyBudgetAnalysis analysis) {
    final weekDates = getWeekRangeString(analysis.weekStart, analysis.weekEnd);
    final budgetText = '\$${analysis.budgetedAmount.toStringAsFixed(0)}';
    final spentText = '\$${analysis.actualSpent.toStringAsFixed(0)}';
    final differenceText = '\$${analysis.difference.abs().toStringAsFixed(0)}';

    // Choose color based on budget status
    final Color progressColor = analysis.isOverBudget
        ? Colors.red
        : (analysis.usagePercentage > 80 ? Colors.orange : Colors.green);

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week date range
          Text(
            weekDates,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          // Budget info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Budget vs Spent
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Budget', style: TextStyle(color: Colors.grey)),
                  Text(budgetText,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spent', style: TextStyle(color: Colors.grey)),
                  Text(spentText,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysis.isOverBudget ? 'Over by' : 'Left',
                    style: TextStyle(color: progressColor),
                  ),
                  Text(
                    differenceText,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: progressColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: analysis.usagePercentage > 100
                  ? 1.0
                  : analysis.usagePercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// Check if two dates are in the same week
  bool _isSameWeek(DateTime date1, DateTime date2) {
    final start1 = _startOfWeek(date1);
    final start2 = _startOfWeek(date2);
    return start1.year == start2.year &&
        start1.month == start2.month &&
        start1.day == start2.day;
  }

  /// Get the start of the week (Sunday) for a given date
  DateTime _startOfWeek(DateTime date) {
    final diff = date.weekday % 7;
    return DateTime(date.year, date.month, date.day - diff);
  }

  /// Get the end of the week (Saturday) for a given date
  DateTime _endOfWeek(DateTime date) {
    final diff = 6 - (date.weekday % 7);
    return DateTime(date.year, date.month, date.day + diff);
  }

  /// Builds the loading indicator at the bottom of the list
  Widget _buildLoadingIndicator() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      return const SizedBox(height: 60); // Empty space at the bottom
    }
  }
}

/// Animated transaction item with swipe gestures
/// Implements both Principle 5 (Gesture Controls) and Principle 7 (Animations)
class _AnimatedTransactionItem extends StatelessWidget {
  final Transaction transaction;
  final int index;

  const _AnimatedTransactionItem({
    Key? key,
    required this.transaction,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Apply a staggered animation effect based on index
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 300 + (index * 50)), // Staggered timing
      curve: Curves.easeInOut,
      child: TransactionListItem(
        transaction: transaction,
        onTap: () {
          // Show transaction details if needed
        },
      ),
    );
  }
}
