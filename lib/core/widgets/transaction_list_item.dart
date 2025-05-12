import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';

/// Widget that displays a single transaction item in the transaction list
class TransactionListItem extends StatelessWidget {
  /// Transaction to display
  final Transaction transaction;

  /// Date formatter for transaction date display
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

  /// Currency formatter for transaction amount display
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
  );

  /// Creates a transaction list item widget
  TransactionListItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildCategoryIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _dateFormat.format(transaction.date),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getFormattedAmount(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: transaction.isIncome
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the category icon for the transaction
  Widget _buildCategoryIcon() {
    final Map<TransactionCategory, IconData> categoryIcons = {
      TransactionCategory.Shopping: Icons.shopping_bag,
      TransactionCategory.Restaurant: Icons.restaurant,
      TransactionCategory.Salary: Icons.account_balance,
      TransactionCategory.Bills: Icons.receipt,
      TransactionCategory.Transportation: Icons.directions_car,
      TransactionCategory.Entertainment: Icons.movie,
      TransactionCategory.Other: Icons.category,
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          categoryIcons[transaction.category] ?? Icons.category,
          color: Colors.black,
          size: 20,
        ),
      ),
    );
  }

  /// Returns the formatted amount with appropriate sign
  String _getFormattedAmount() {
    // Display positive numbers with + sign, negative numbers already have -
    final prefix = transaction.isIncome ? '+' : '-';
    return '$prefix\$${_currencyFormat.format(transaction.amount.abs())}';
  }
}
