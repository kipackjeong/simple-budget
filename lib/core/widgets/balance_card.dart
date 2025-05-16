import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget that displays the balance card on the main screen
class BalanceCard extends StatelessWidget {
  /// The total account balance
  final double balance;

  /// The total income amount
  final double totalIncome;

  /// The total expenses amount
  final double totalExpenses;

  /// Currency formatter
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Creates a balance card widget
  BalanceCard({
    Key? key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Total Balance amount styled for high contrast
            Text(
              _currencyFormat.format(balance),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: balance >= 0 ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Income summary: green color
                _buildSummaryColumn(
                  'Income',
                  totalIncome,
                  Icons.arrow_upward,
                  Colors.green,
                ),
                // Expenses summary: red color
                _buildSummaryColumn(
                  'Expenses',
                  totalExpenses,
                  Icons.arrow_downward,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build income/expense summary columns
  Widget _buildSummaryColumn(
    String label,
    double amount,
    IconData iconData,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(iconData, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Amount text inherits color from parent _buildSummaryColumn argument (Colors.green or Colors.red)
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
