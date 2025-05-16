import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/periodic_budget.dart';
import '../providers/periodic_budget_providers.dart';
import 'budget_management_screen.dart';

/// Screen for displaying a list of all periodic budgets with a clean, modern UI
class BudgetsListScreen extends ConsumerWidget {
  const BudgetsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(periodicBudgetsProvider);

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

  Widget _buildBudgetList(BuildContext context, List<PeriodicBudget> budgets) {
    final periodicBudgets = budgets;

    if (periodicBudgets.isEmpty) {
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
            // Periodic Budgets Section
            _buildSectionHeader('Periodic'),
            const SizedBox(height: 16),
            _buildPeriodicBudgetCards(context, periodicBudgets),
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

  Widget _buildPeriodicBudgetCards(
      BuildContext context, List<PeriodicBudget> budgets) {
    // Group budgets by period (monthly/weekly)
    final monthlyBudgets =
        budgets.where((b) => b.period.toLowerCase() == 'monthly').toList();
    final weeklyBudgets =
        budgets.where((b) => b.period.toLowerCase() == 'weekly').toList();

    return Column(
      children: [
        // Monthly budgets
        if (monthlyBudgets.isNotEmpty)
          ...monthlyBudgets.map((budget) => _buildBudgetCard(
                context,
                budget,
                Icons.calendar_month,
                'Monthly',
              )),

        // Weekly budgets
        if (weeklyBudgets.isNotEmpty)
          ...weeklyBudgets.map((budget) => _buildBudgetCard(
                context,
                budget,
                Icons.calendar_view_week,
                'Weekly',
              )),
      ],
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    PeriodicBudget budget,
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
