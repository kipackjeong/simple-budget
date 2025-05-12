import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/core/utils/animation_utils.dart';
import 'package:spending_tracker/core/widgets/transaction_list_item.dart';
import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';

/// A widget that displays transactions with infinite scrolling
/// Implements Principle 3: Vertical Navigation and Infinite Scroll
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
  ConsumerState<InfiniteTransactionList> createState() => _InfiniteTransactionListState();
}

class _InfiniteTransactionListState extends ConsumerState<InfiniteTransactionList> {
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
              Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
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

    // Determine transactions to display
    final displayedTransactions = widget.transactions
        .take(_displayCount)
        .toList();
        
    // Render the list with pull-to-refresh
    final Widget res = RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displayedTransactions.length + 1, // +1 for loading indicator
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index == displayedTransactions.length) {
            return _buildLoadingIndicator();
          }
          
          // Get transaction for this index
          final transaction = displayedTransactions[index];
          
          // Create the animated transaction item with swipe actions
          return _AnimatedTransactionItem(
            key: ValueKey(transaction.id),
            transaction: transaction,
            index: index,
          );
        },
      ),
    );
    
    return res;
  }

  /// Builds the loading indicator at the bottom of the list
  Widget _buildLoadingIndicator() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_displayCount < widget.transactions.length) {
      // Show a button to load more manually
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: ElevatedButton(
            onPressed: _loadMore,
            child: const Text('Load More'),
          ),
        ),
      );
    } else {
      // We've reached the end of the list
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'End of transaction history',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
  }
}

/// Animated transaction item with swipe gestures
/// Implements both Principle 5 (Gesture Controls) and Principle 7 (Animations)
class _AnimatedTransactionItem extends StatelessWidget {
  /// Transaction to display
  final Transaction transaction;
  
  /// Index in the list (used for staggered animations)
  final int index;

  const _AnimatedTransactionItem({
    Key? key,
    required this.transaction,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a dismissible widget for swipe-to-delete/edit functionality
    final Widget res = Dismissible(
      key: ValueKey('dismissible-${transaction.id}'),
      direction: DismissDirection.horizontal,
      
      // Left to right swipe (edit)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.blue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      
      // Right to left swipe (delete)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      
      // Handle dismiss action
      onDismissed: (direction) {
        // In a real app, these would call respective functions
        if (direction == DismissDirection.startToEnd) {
          // Edit action
          debugPrint('Edit transaction: ${transaction.id}');
        } else {
          // Delete action
          debugPrint('Delete transaction: ${transaction.id}');
        }
      },
      
      // Confirmation dialog before dismissing
      confirmDismiss: (direction) async {
        final String action = direction == DismissDirection.startToEnd
            ? 'edit'
            : 'delete';
        
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm $action'),
            content: Text('Are you sure you want to $action this transaction?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ?? false;
      },
      
      // The actual transaction item
      child: TransactionListItem(transaction: transaction),
    );
    
    // Apply fade and slide animation
    return res.fadeSlideIn(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
    );
  }
}
