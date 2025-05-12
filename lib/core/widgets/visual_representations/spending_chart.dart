import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:spending_tracker/shared/themes/app_theme.dart';

/// A chart that visualizes spending data by category
/// Implements Principle 6: Visual Data Representation
class SpendingChart extends StatelessWidget {
  /// List of transactions to visualize
  final List<Transaction> transactions;

  /// Height of the chart
  final double height;

  /// Width of the chart (defaults to match parent)
  final double? width;

  /// Whether to animate the chart when it first appears
  final bool animate;

  /// Creates a spending chart widget
  const SpendingChart({
    Key? key,
    required this.transactions,
    this.height = 220,
    this.width,
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: Text('No transaction data available'),
        ),
      );
    }

    // Use the expense transactions only
    final expenseTransactions =
        transactions.where((t) => t.amount < 0).toList();

    if (expenseTransactions.isEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: Text('No expense data to visualize'),
        ),
      );
    }

    // Group transactions by category and calculate total amount per category
    final Map<TransactionCategory, double> categoryTotals = {};

    for (final transaction in expenseTransactions) {
      final category = transaction.category;
      final amount = transaction.amount.abs();

      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      } else {
        categoryTotals[category] = amount;
      }
    }

    // Prepare data for the pie chart
    final List<PieChartSectionData> sections = [];

    // Define colors for different categories
    final categoryColors = {
      TransactionCategory.Shopping: Colors.blue,
      TransactionCategory.Restaurant: Colors.orange,
      TransactionCategory.Bills: Colors.red,
      TransactionCategory.Transportation: Colors.green,
      TransactionCategory.Entertainment: Colors.purple,
      TransactionCategory.Other: Colors.grey,
    };

    // Calculate total expenses for percentage calculation
    final totalExpenses =
        categoryTotals.values.reduce((sum, amount) => sum + amount);

    // Create pie sections with appropriate sizes and colors
    categoryTotals.forEach((category, amount) {
      final percentage = amount / totalExpenses;
      final title = '${(percentage * 100).toStringAsFixed(0)}%';

      sections.add(
        PieChartSectionData(
          color: categoryColors[category] ?? Colors.grey,
          value: amount,
          title: title,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.55,
        ),
      );
    });

    // Create the chart with smooth animations for a polished look
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              // Touch feedback could be implemented here
            },
          ),
        ),
        swapAnimationDuration:
            animate ? AppTheme.animationDuration : Duration.zero,
        swapAnimationCurve: AppTheme.animationCurve,
      ),
    );
  }
}
