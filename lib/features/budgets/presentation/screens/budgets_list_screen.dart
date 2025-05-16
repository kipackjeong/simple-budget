import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/monthly_budget.dart';
import '../providers/monthly_budget_providers.dart';
import 'budget_management_screen.dart';

/// Displays a list of all monthly budgets.
class BudgetsListScreen extends ConsumerWidget {
  const BudgetsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(monthlyBudgetsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: budgetsAsync.when(
        data: (budgets) => _buildBudgetList(context, budgets),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading budgets: $error',
              style: const TextStyle(color: Colors.red)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const BudgetManagementScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetList(BuildContext context, List<MonthlyBudget> budgets) {
    final monthlyBudgets = budgets;

    if (monthlyBudgets.isEmpty) {
      return const Center(
        child: Text(
          'No budgets found.\nTap + to add a new budget.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Budgets Section
            _buildSectionHeader('Monthly'),
            const SizedBox(height: 16),
            _buildMonthlyBudgetCards(context, monthlyBudgets),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// Builds monthly budget cards
  Widget _buildMonthlyBudgetCards(
    BuildContext context,
    List<MonthlyBudget> budgets,
  ) {
    if (budgets.isEmpty) {
      // No monthly budget found for user
      return const Center(
        child: Text(
          'No monthly budget set. Please add your monthly budget.',
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    }
    if (budgets.length > 1) {
      // Data integrity error: more than one monthly budget
      return const Center(
        child: Text(
          'Error: Multiple monthly budgets found. Please contact support.',
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    }

    final MonthlyBudget monthlyBudget = budgets.first;
    // Derive weekly budget from monthly (average weeks per month)
    final double weeklyAmount = monthlyBudget.amount / 4.345;

    return Column(
      children: [
        // Monthly budget card (editable)
        _buildBudgetCard(
          context,
          monthlyBudget,
          Icons.calendar_month,
          'Monthly',
        ),
        const SizedBox(height: 16),
        // Derived weekly budget card (read-only)
        _buildDerivedWeeklyBudgetCard(context, monthlyBudget, weeklyAmount),
      ],
    );
  }

  /// Builds a read-only weekly budget card derived from the monthly budget.
  Widget _buildDerivedWeeklyBudgetCard(
    BuildContext context,
    MonthlyBudget monthlyBudget,
    double weeklyAmount,
  ) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.calendar_view_week, color: Colors.blueGrey),
        title: const Text(
          'Weekly (derived)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '≈ ${weeklyAmount.toStringAsFixed(2)} ${monthlyBudget.currency}',
          style: const TextStyle(color: Colors.black87),
        ),
        trailing: const Icon(Icons.lock_outline, color: Colors.grey),
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    MonthlyBudget budget,
    IconData icon,
    String periodLabel,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue[800]),
            const SizedBox(width: 16),
            Text(
              periodLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '\$${budget.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
