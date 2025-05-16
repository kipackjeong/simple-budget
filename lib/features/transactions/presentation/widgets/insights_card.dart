import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/features/budgets/presentation/providers/budget_analysis_providers.dart';
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
    // Watch the budget analysis provider
    final budgetAnalysisAsync = ref.watch(weeklyBudgetAnalysisProvider);

    return budgetAnalysisAsync.when(
      data: (weeklyAnalyses) {
        // Generate insights based on transaction data and budget analysis
        final insights = _generateInsights(transactions, weeklyAnalyses);

        if (insights.isEmpty) {
          return const SizedBox(); // No insights to display
        }

        // Card widget with insights (same as before)
        return _buildInsightsCard(insights);
      },
      loading: () {
        // Generate insights without budget data while loading
        final insights = _generateInsights(transactions, []);

        if (insights.isEmpty) {
          return const SizedBox(); // No insights to display
        }

        return _buildInsightsCard(insights);
      },
      error: (_, __) {
        // Generate insights without budget data on error
        final insights = _generateInsights(transactions, []);

        if (insights.isEmpty) {
          return const SizedBox(); // No insights to display
        }

        return _buildInsightsCard(insights);
      },
    );
  }

  /// Build the insights card with animated items
  Widget _buildInsightsCard(List<FinancialInsight> insights) {
    // Card widget with insights
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
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

  /// Generate financial insights based on transaction history and budget data
  List<FinancialInsight> _generateInsights(List<Transaction> transactions,
      List<WeeklyBudgetAnalysis> weeklyAnalyses) {
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

      // Add budget insights if we have budget data
      if (weeklyAnalyses.isNotEmpty) {
        // Get the most recent week's budget data
        final currentWeek = weeklyAnalyses.first;

        // Check if current week is over budget
        if (currentWeek.isOverBudget) {
          insights.add(
            FinancialInsight(
              message:
                  'You are \$${currentWeek.difference.abs().toStringAsFixed(0)} over your weekly budget of \$${currentWeek.budgetedAmount.toStringAsFixed(0)}.',
              icon: Icons.warning,
              actionable:
                  'Consider reducing expenses for the rest of the week.',
              isWarning: true,
            ),
          );
        }
        // Check if approaching budget limit (80% or more)
        else if (currentWeek.usagePercentage >= 80) {
          insights.add(
            FinancialInsight(
              message:
                  'You have used ${currentWeek.usagePercentage.toStringAsFixed(0)}% of your weekly budget.',
              icon: Icons.trending_up,
              actionable:
                  'You have \$${currentWeek.difference.toStringAsFixed(0)} left for the week.',
              isWarning: true,
            ),
          );
        }
        // Check for consistent under-budget weeks
        else if (weeklyAnalyses.length >= 3) {
          final allUnderBudget =
              weeklyAnalyses.take(3).every((week) => !week.isOverBudget);
          if (allUnderBudget) {
            insights.add(
              FinancialInsight(
                message:
                    'You have stayed under budget for the last ${weeklyAnalyses.take(3).length} weeks.',
                icon: Icons.emoji_events,
                actionable: 'Great job maintaining your spending discipline!',
                isPositive: true,
              ),
            );
          }
        }

        // Check for spending trend compared to budget
        if (weeklyAnalyses.length >= 2) {
          final currentWeek = weeklyAnalyses.first;
          final previousWeek = weeklyAnalyses[1];

          final spendingChange =
              currentWeek.actualSpent - previousWeek.actualSpent;
          final percentChange = previousWeek.actualSpent > 0
              ? (spendingChange / previousWeek.actualSpent * 100)
              : 0.0;

          if (percentChange > 20) {
            insights.add(
              FinancialInsight(
                message:
                    'Your spending increased by ${percentChange.abs().toStringAsFixed(0)}% compared to last week.',
                icon: Icons.trending_up,
                actionable:
                    'Review your recent expenses to identify areas to cut back.',
                isWarning: true,
              ),
            );
          } else if (percentChange < -20) {
            insights.add(
              FinancialInsight(
                message:
                    'Your spending decreased by ${percentChange.abs().toStringAsFixed(0)}% compared to last week.',
                icon: Icons.trending_down,
                actionable: 'Keep up the good work!',
                isPositive: true,
              ),
            );
          }
        }
      }

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
          content = TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - opacity)),
                  child: child,
                ),
              );
            },
            child: content,
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
