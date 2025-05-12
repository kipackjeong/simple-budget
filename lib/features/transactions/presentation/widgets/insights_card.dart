import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/core/utils/animation_utils.dart';
import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:spending_tracker/shared/themes/app_theme.dart';

/// Widget that displays personalized financial insights
/// Implements Principle 4: Personalized Insights
class InsightsCard extends ConsumerWidget {
  /// List of transactions to analyze
  final List<Transaction> transactions;

  /// Creates an insights card widget
  const InsightsCard({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Generate insights based on transaction data
    final insights = _generateInsights(transactions);

    if (insights.isEmpty) {
      return const SizedBox(); // No insights to display
    }

    // Card widget with insights
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            const Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: AppTheme.accentColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Financial Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            // Display insights with animations for engagement
            ...insights.asMap().entries.map((entry) {
              final index = entry.key;
              final insight = entry.value;
              // Stagger animations for a more engaging effect
              return _InsightItem(
                insight: insight,
                delayMs: 100 * index,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Generate financial insights based on transaction history
  List<FinancialInsight> _generateInsights(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return [];
    }

    final List<FinancialInsight> insights = [];

    try {
      // Calculate total expenses
      final expenses = transactions
          .where((t) => t.amount < 0)
          .fold(0.0, (sum, t) => sum + t.amount.abs());

      // Calculate total income
      final income = transactions
          .where((t) => t.amount > 0)
          .fold(0.0, (sum, t) => sum + t.amount);

      // Group expenses by category
      final Map<TransactionCategory, double> expensesByCategory = {};
      for (final transaction in transactions.where((t) => t.amount < 0)) {
        final category = transaction.category;
        final amount = transaction.amount.abs();

        if (expensesByCategory.containsKey(category)) {
          expensesByCategory[category] =
              (expensesByCategory[category] ?? 0) + amount;
        } else {
          expensesByCategory[category] = amount;
        }
      }

      // Find the highest expense category
      TransactionCategory? highestCategory;
      double highestAmount = 0;

      expensesByCategory.forEach((category, amount) {
        if (amount > highestAmount) {
          highestAmount = amount;
          highestCategory = category;
        }
      });

      // Calculate savings rate
      final savingsRate = income > 0 ? (income - expenses) / income : 0;

      // Add insight about highest expense category
      if (highestCategory != null && expenses > 0) {
        final percentage = (highestAmount / expenses * 100).toStringAsFixed(0);
        insights.add(
          FinancialInsight(
            message:
                'Your highest spending category is ${highestCategory!.name} at $percentage% of expenses.',
            icon: Icons.pie_chart,
            actionable: 'Consider setting a budget for this category.',
          ),
        );
      }

      // Add insight about savings rate
      if (income > 0) {
        if (savingsRate < 0.1) {
          insights.add(
            FinancialInsight(
              message:
                  'Your savings rate is ${(savingsRate * 100).toStringAsFixed(0)}%, which is below the recommended 20%.',
              icon: Icons.savings,
              actionable:
                  'Try to reduce non-essential expenses to increase your savings.',
              isWarning: true,
            ),
          );
        } else if (savingsRate >= 0.2) {
          insights.add(
            FinancialInsight(
              message:
                  'Great job! Your savings rate is ${(savingsRate * 100).toStringAsFixed(0)}%, above the recommended 20%.',
              icon: Icons.thumb_up,
              actionable: 'Consider investing your extra savings for growth.',
              isPositive: true,
            ),
          );
        }
      }

      // Add specific category insights
      if (expensesByCategory.containsKey(TransactionCategory.Restaurant) &&
          expensesByCategory[TransactionCategory.Restaurant]! > 200) {
        insights.add(
          FinancialInsight(
            message:
                'You spent \$${expensesByCategory[TransactionCategory.Restaurant]!.toStringAsFixed(0)} on restaurants recently.',
            icon: Icons.restaurant,
            actionable:
                'Cooking at home more often could help reduce expenses.',
            isWarning: true,
          ),
        );
      }

      // Balance insight
      final balance = income - expenses;
      if (balance < 100 && income > 0) {
        insights.add(
          FinancialInsight(
            message:
                'Your current balance is getting low at \$${balance.toStringAsFixed(0)}.',
            icon: Icons.account_balance_wallet,
            actionable:
                'Review your upcoming expenses to avoid going negative.',
            isWarning: true,
          ),
        );
      }
    } catch (err) {
      debugPrint('Error generating insights: $err');
    }

    return insights;
  }
}

/// Widget that displays a single financial insight with animation
class _InsightItem extends StatelessWidget {
  /// Insight to display
  final FinancialInsight insight;

  /// Delay in milliseconds before starting the animation
  final int delayMs;

  const _InsightItem({
    required this.insight,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delayMs)),
      builder: (context, snapshot) {
        // Only animate once the delay is complete
        final shouldAnimate = snapshot.connectionState == ConnectionState.done;

        Widget content = Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with color based on insight type
              Icon(
                insight.icon,
                color: insight.isWarning
                    ? AppTheme.expenseColor
                    : insight.isPositive
                        ? AppTheme.incomeColor
                        : AppTheme.secondaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main insight message
                    Text(
                      insight.message,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (insight.actionable != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        // Actionable advice
                        child: Text(
                          insight.actionable!,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

        // Apply animation if needed
        if (shouldAnimate) {
          content = content.fadeSlideIn(
            duration: const Duration(milliseconds: 500),
            distance: 20,
          );
        }

        return content;
      },
    );
  }
}

/// Model representing a financial insight
class FinancialInsight {
  /// Main message of the insight
  final String message;

  /// Icon to display with the insight
  final IconData icon;

  /// Actionable advice for the user (optional)
  final String? actionable;

  /// Whether this insight is a warning
  final bool isWarning;

  /// Whether this insight is positive
  final bool isPositive;

  /// Creates a financial insight
  const FinancialInsight({
    required this.message,
    required this.icon,
    this.actionable,
    this.isWarning = false,
    this.isPositive = false,
  });
}
