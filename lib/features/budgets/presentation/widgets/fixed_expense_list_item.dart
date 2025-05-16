import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/fixed_expense.dart';

/// Displays a single fixed expense item in a list.
class FixedExpenseListItem extends StatelessWidget {
  /// The fixed expense to display
  final FixedExpense expense;
  
  /// Callback when edit is tapped
  final VoidCallback? onEdit;
  
  /// Callback when delete is tapped
  final VoidCallback? onDelete;
  
  /// Currency formatter for expense amount display
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  
  /// Date formatter for due date display
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

  /// Creates a fixed expense list item widget
  FixedExpenseListItem({
    Key? key,
    required this.expense,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    // Get appropriate icon based on category
    IconData categoryIcon = _getCategoryIcon(expense.category);
    
    // Get frequency label
    String frequencyLabel = _getFrequencyLabel(expense.frequency);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Dismissible(
        key: Key(expense.id),
        background: Container(
          padding: const EdgeInsets.only(right: 20.0),
          alignment: Alignment.centerRight,
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          if (onDelete != null) {
            onDelete!();
            return true;
          }
          return false;
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            child: Icon(
              categoryIcon,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            expense.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${_dateFormat.format(expense.dueDate)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.repeat,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    frequencyLabel,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(expense.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns an appropriate icon based on expense category
  IconData _getCategoryIcon(String category) {
    final String normalizedCategory = category.toLowerCase();
    
    if (normalizedCategory.contains('home') || 
        normalizedCategory.contains('rent') || 
        normalizedCategory.contains('mortgage')) {
      return Icons.home;
    } else if (normalizedCategory.contains('car') || 
               normalizedCategory.contains('transport')) {
      return Icons.directions_car;
    } else if (normalizedCategory.contains('food') || 
               normalizedCategory.contains('grocery')) {
      return Icons.shopping_basket;
    } else if (normalizedCategory.contains('util') || 
               normalizedCategory.contains('electric') || 
               normalizedCategory.contains('water')) {
      return Icons.power;
    } else if (normalizedCategory.contains('phone') || 
               normalizedCategory.contains('internet') || 
               normalizedCategory.contains('wifi')) {
      return Icons.wifi;
    } else if (normalizedCategory.contains('insurance')) {
      return Icons.health_and_safety;
    } else if (normalizedCategory.contains('subscription') || 
               normalizedCategory.contains('service')) {
      return Icons.subscriptions;
    } else {
      return Icons.attach_money;
    }
  }

  /// Returns a formatted label for frequency
  String _getFrequencyLabel(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'monthly':
        return 'Paid Monthly';
      case 'quarterly':
        return 'Paid Quarterly';
      case 'annual':
        return 'Paid Annually';
      default:
        return 'Recurring Payment';
    }
  }
}
