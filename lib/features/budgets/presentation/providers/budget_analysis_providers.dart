import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/features/budgets/presentation/providers/budget_config_providers.dart';
import 'package:spending_tracker/features/transactions/presentation/providers/transaction_providers.dart';

/// Model for weekly budget analysis
class WeeklyBudgetAnalysis {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double budgetedAmount;
  final double actualSpent;
  final double difference;
  final double usagePercentage;

  WeeklyBudgetAnalysis({
    required this.weekStart,
    required this.weekEnd,
    required this.budgetedAmount,
    required this.actualSpent,
  }) : difference = budgetedAmount - actualSpent.abs(),
       usagePercentage = budgetedAmount > 0 ? (actualSpent.abs() / budgetedAmount) * 100 : 0;

  bool get isOverBudget => difference < 0;
}

/// Provider for weekly budget analysis
final weeklyBudgetAnalysisProvider = FutureProvider<List<WeeklyBudgetAnalysis>>((ref) async {
  final List<WeeklyBudgetAnalysis> result = [];
  
  try {
    // Get transactions and monthly budget config
    final transactions = await ref.watch(transactionsProvider.future);
    final budgetConfig = await ref.watch(budgetConfigProvider.future);

    if (transactions.isEmpty || budgetConfig == null) {
      return result;
    }

    // Calculate weekly budget from monthly budget
    final double totalWeeklyBudget = budgetConfig.monthlyAmount / 4;
    if (totalWeeklyBudget <= 0) {
      return result;
    }
    
    // Get range of weeks from transactions
    final sortedTransactions = [...transactions]
      ..sort((a, b) => a.date.compareTo(b.date));
    
    if (sortedTransactions.isEmpty) {
      return result;
    }
    
    final oldestTransaction = sortedTransactions.first;
    final newestTransaction = sortedTransactions.last;
    
    // Use the most recent 8 weeks for analysis
    DateTime startDate = DateTime.now().subtract(const Duration(days: 56)); // 8 weeks ago
    if (oldestTransaction.date.isAfter(startDate)) {
      startDate = _startOfWeek(oldestTransaction.date);
    }
    
    final endDate = _endOfWeek(newestTransaction.date);
    
    // Calculate weekly stats
    DateTime currentWeekStart = startDate;
    while (currentWeekStart.isBefore(endDate)) {
      final currentWeekEnd = _endOfWeek(currentWeekStart);
      
      // Get transactions for this week
      final weekTransactions = transactions.where((tx) {
        return tx.date.isAfter(currentWeekStart) && 
               tx.date.isBefore(currentWeekEnd.add(const Duration(days: 1)));
      }).toList();
      
      // Calculate expenses for this week (negative amounts)
      final weeklyExpenses = weekTransactions
          .where((tx) => tx.amount < 0)
          .fold(0.0, (sum, tx) => sum + tx.amount.abs());
          
      result.add(WeeklyBudgetAnalysis(
        weekStart: currentWeekStart,
        weekEnd: currentWeekEnd,
        budgetedAmount: totalWeeklyBudget,
        actualSpent: weeklyExpenses,
      ));
      
      // Move to next week
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }
    
    // Sort by week (newest first)
    result.sort((a, b) => b.weekStart.compareTo(a.weekStart));
    
    // Return the most recent weeks (up to 8)
    return result.take(8).toList();
  } catch (err) {
    print('Error calculating budget analysis: $err');
    return [];
  }
});

/// Get the start of the week (Sunday) for a given date
DateTime _startOfWeek(DateTime date) {
  final diff = date.weekday % 7;
  return DateTime(date.year, date.month, date.day - diff).subtract(const Duration(hours: 12));
}

/// Get the end of the week (Saturday) for a given date
DateTime _endOfWeek(DateTime date) {
  final diff = 6 - (date.weekday % 7);
  return DateTime(date.year, date.month, date.day + diff).add(const Duration(hours: 12));
}

/// Format a date as a short month day string (e.g. "May 12")
String formatShortDate(DateTime date) {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}';
}

/// Get week range as a formatted string (e.g. "May 1 - May 7")
String getWeekRangeString(DateTime start, DateTime end) {
  return '${formatShortDate(start)} - ${formatShortDate(end)}';
}
