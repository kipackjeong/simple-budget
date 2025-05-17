import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/period_type.dart';
import 'supabase_service.dart';

/// Service for budget-related operations
class BudgetService extends SupabaseService {
  static const String _periodBudgetsTable = 'period_budgets';
  static const String _categoryBudgetsTable = 'category_budgets';

  BudgetService({SupabaseClient? supabaseClient}) : super(supabaseClient: supabaseClient);

  /// Get period budget for a specific period type and date range
  Future<Map<String, dynamic>?> getPeriodBudget({
    required PeriodType periodType,
    required DateTime periodStart,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to fetch period budget');
    }
    
    try {
      final res = await supabase
          .from(_periodBudgetsTable)
          .select()
          .eq('user_id', currentUserId!)
          .eq('period', periodType.toDbString())
          .eq('period_start', periodStart.toIso8601String().split('T')[0])
          .maybeSingle();
      
      return res;
    } catch (err) {
      _logError('Failed to fetch period budget', err);
      throw Exception('Failed to load period budget');
    }
  }

  /// Get all category budgets for a specific period type and date range
  Future<List<Map<String, dynamic>>> getCategoryBudgets({
    required PeriodType periodType,
    required DateTime periodStart,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to fetch category budgets');
    }
    
    try {
      final res = await supabase
          .from(_categoryBudgetsTable)
          .select('*, categories(*)')
          .eq('user_id', currentUserId!)
          .eq('period', periodType.toDbString())
          .eq('period_start', periodStart.toIso8601String().split('T')[0]);
      
      return List<Map<String, dynamic>>.from(res);
    } catch (err) {
      _logError('Failed to fetch category budgets', err);
      throw Exception('Failed to load category budgets');
    }
  }

  /// Update a specific category budget amount
  Future<Map<String, dynamic>> updateCategoryBudget({
    required String categoryBudgetId,
    required double amount,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to update category budget');
    }
    
    try {
      final res = await supabase
          .from(_categoryBudgetsTable)
          .update({'amount': amount})
          .eq('id', categoryBudgetId)
          .eq('user_id', currentUserId!) // Ensure user owns this budget
          .select()
          .single();
      
      return res;
    } catch (err) {
      _logError('Failed to update category budget', err);
      throw Exception('Failed to update category budget');
    }
  }

  /// Get current calendar period bounds (monthly/weekly) based on the current date
  Map<String, DateTime> getCurrentPeriodBounds(PeriodType periodType, [DateTime? date]) {
    final now = date ?? DateTime.now();
    DateTime start, end;

    if (periodType == PeriodType.monthly) {
      // First day of current month to last day of current month
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0); // Last day of month
    } else if (periodType == PeriodType.weekly) {
      // Start of week (Monday) to end of week (Sunday)
      final weekday = now.weekday; // 1 = Monday, 7 = Sunday
      start = now.subtract(Duration(days: weekday - 1));
      end = start.add(const Duration(days: 6));
      
      // Reset to start of day for start and end of day for end
      start = DateTime(start.year, start.month, start.day);
      end = DateTime(end.year, end.month, end.day, 23, 59, 59);
    } else if (periodType == PeriodType.biweekly) {
      // Simplified biweekly logic - first half or second half of month
      final isFirstHalf = now.day <= 15;
      if (isFirstHalf) {
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month, 15, 23, 59, 59);
      } else {
        start = DateTime(now.year, now.month, 16);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      }
    } else { // yearly
      // Current year
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31, 23, 59, 59);
    }

    return {
      'start': start,
      'end': end,
    };
  }

  /// Calculate budget progress (spent vs allocated) for the current period
  Future<Map<String, dynamic>> getBudgetProgress(PeriodType periodType) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to calculate budget progress');
    }
    
    try {
      final period = getCurrentPeriodBounds(periodType);
      final start = period['start']!;
      
      // 1. Get period budget
      final periodBudget = await getPeriodBudget(
        periodType: periodType,
        periodStart: start,
      );
      
      if (periodBudget == null) {
        return {
          'status': 'no_budget',
          'message': 'No budget defined for this period'
        };
      }
      
      // 2. Get category budgets
      final categoryBudgets = await getCategoryBudgets(
        periodType: periodType,
        periodStart: start,
      );
      
      // 3. Get transaction summary for this period
      final res = await client.rpc(
        'sum_transactions_in_period',
        params: {
          'uid': currentUserId,
          'start_date': start.toIso8601String().split('T')[0],
          'end_date': period['end']!.toIso8601String().split('T')[0],
        },
      );
      
      final totalIncome = (res['income_sum'] ?? 0).toDouble();
      final totalExpense = (res['expense_sum'] ?? 0).toDouble();
      final netAmount = totalIncome + totalExpense; // expense is negative
      
      // 4. Calculate percentage spent of max budget
      final maxBudget = (periodBudget['max_budget'] ?? 0).toDouble();
      final percentSpent = maxBudget > 0 ? (netAmount / maxBudget * 100).clamp(0, 100) : 0;
      
      return {
        'status': 'success',
        'period_start': start.toIso8601String().split('T')[0],
        'period_end': period['end']!.toIso8601String().split('T')[0],
        'total_income': totalIncome,
        'total_expense': totalExpense,
        'net_amount': netAmount,
        'max_budget': maxBudget,
        'percent_spent': percentSpent,
        'category_budgets': categoryBudgets,
      };
    } catch (err) {
      _logError('Failed to calculate budget progress', err);
      throw Exception('Failed to calculate budget progress');
    }
  }
  
  /// Log errors to console and potentially to a monitoring service
  void _logError(String message, dynamic error) {
    // In a real app, this could use proper logging/monitoring
    // ignore: avoid_print
    print('ERROR: $message - ${error.toString()}');
  }
}
