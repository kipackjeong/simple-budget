import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget_config.dart';
import '../providers/budget_config_providers.dart';
import '../providers/fixed_expense_providers.dart';
import 'budget_config_screen.dart';
import 'fixed_expenses_screen.dart';

/// Displays the budget configuration dashboard.
class BudgetDashboardScreen extends ConsumerWidget {
  const BudgetDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetConfigAsync = ref.watch(budgetConfigProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: budgetConfigAsync.when(
        data: (config) => _buildBudgetDashboard(context, config, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading budget configuration: $error',
              style: const TextStyle(color: Colors.red)),
        ),
      ),
      floatingActionButton: budgetConfigAsync.when(
        data: (config) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed Expenses Button
            FloatingActionButton.small(
              heroTag: 'fixed_expenses',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FixedExpensesScreen(),
                ),
              ),
              child: const Icon(Icons.account_balance_wallet),
              tooltip: 'Manage Fixed Expenses',
            ),
            const SizedBox(height: 16),
            // Main Budget Config Button
            FloatingActionButton(
              heroTag: 'budget_config',
              onPressed: () => _navigateToBudgetConfig(context, config),
              child: Icon(config == null ? Icons.add : Icons.edit),
            ),
          ],
        ),
        loading: () => const SizedBox(),
        error: (_, __) => FloatingActionButton(
          onPressed: () => _navigateToBudgetConfig(context, null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _navigateToBudgetConfig(BuildContext context, BudgetConfig? config) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BudgetConfigScreen(initialConfig: config),
      ),
    );
  }

  Widget _buildBudgetDashboard(
      BuildContext context, BudgetConfig? config, WidgetRef ref) {
    if (config == null) {
      return const Center(
        child: Text(
          'No budget configured.\nTap + to set up your monthly budget.',
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
            _buildSectionHeader('Your Budget'),
            const SizedBox(height: 24),

            // Monthly Budget Card
            _buildBudgetCard(
              context,
              Icons.calendar_month,
              'Monthly Budget',
              config.monthlyAmount,
              Colors.blue.shade800,
            ),

            const SizedBox(height: 16),

            // Weekly Budget Card (calculated)
            _buildBudgetCard(
              context,
              Icons.calendar_view_week,
              'Weekly Budget',
              config.weeklyAmount,
              Colors.green.shade700,
            ),

            const SizedBox(height: 32),

            // Budget Information
            _buildInfoSection(context, config, ref),

            const SizedBox(height: 24),

            // Transition Information
            _buildTransitionSection(),
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

  Widget _buildBudgetCard(
    BuildContext context,
    IconData icon,
    String label,
    double amount,
    Color accentColor,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: accentColor),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Budget Type Chip (using default since type property removed)
            Container(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: const Text(
                  'Monthly Budget',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: Colors.indigo.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, BudgetConfig config, WidgetRef ref) {
    final updatedDate = _formatDate(config.updatedAt);
    
    // Get fixed expenses info using the provider
    final fixedExpensesAsync = ref.watch(totalFixedExpensesProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          
          // Fixed Expenses Information
          fixedExpensesAsync.when(
            data: (fixedExpensesTotal) => fixedExpensesTotal > 0 ? ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_wallet, color: Colors.indigo),
              title: const Text('Fixed Expenses'),
              subtitle: Text(
                'Monthly: \$${fixedExpensesTotal.toStringAsFixed(2)}\nPercentage of Budget: ${((fixedExpensesTotal / config.monthlyAmount) * 100).toStringAsFixed(1)}%'
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FixedExpensesScreen(),
                  ),
                ),
              ),
            ) : const SizedBox.shrink(),
            loading: () => const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.account_balance_wallet, color: Colors.grey),
              title: Text('Fixed Expenses'),
              subtitle: Text('Loading...'),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.update, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Last updated: $updatedDate',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blue.shade800),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Your weekly budget is automatically calculated as 1/4 of your monthly budget.',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Builds an informational section about the transition between budget systems
  Widget _buildTransitionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Budget System Update',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "We've upgraded to a new budget system. The new system uses a monthly budget configuration that automatically calculates your weekly budget as 1/4 of your monthly amount.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your previous budgets are still available in the 'Budget List' tab. Any new budgets should be created using this new configuration system.",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
