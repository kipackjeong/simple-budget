import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/features/budgets/presentation/providers/monthly_budget_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/monthly_budget.dart';
// TODO: Replace with monthly budget provider imports if needed.

/// Screen for managing periodic budget settings with a clean, minimal UI
class BudgetManagementScreen extends ConsumerStatefulWidget {
  const BudgetManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BudgetManagementScreen> createState() =>
      _BudgetManagementScreenState();
}

class _BudgetManagementScreenState
    extends ConsumerState<BudgetManagementScreen> {
  /// Determines if the budget is fixed or flexible
  bool _isFixed = true;

  /// Budget period (Weekly/Monthly)
  String _period = 'Weekly';

  /// Amount input controller
  final TextEditingController _amountController = TextEditingController();

  /// Notes input controller (optional)
  final TextEditingController _notesController = TextEditingController();

  /// Calculated weekly amount (if monthly selected)
  double? _weeklyAmount;

  /// Calculate weekly equivalent of monthly budget
  void _calculateWeeklyAmount() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && _period == 'Monthly') {
      setState(() => _weeklyAmount = amount / 4);
    } else {
      setState(() => _weeklyAmount = null);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use theme for styling elements
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title:
              const Text('Add Budget', style: TextStyle(color: Colors.black))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Budget Type
              _buildSectionLabel('Budget Type'),
              const SizedBox(height: 12),
              _buildBudgetTypeSelector(),

              const SizedBox(height: 24),

              // Budget Period
              _buildSectionLabel('Budget Period'),
              const SizedBox(height: 12),
              _buildPeriodSelector(),

              const SizedBox(height: 24),

              // Budget Amount
              _buildSectionLabel('Budget Amount'),
              const SizedBox(height: 12),
              _buildAmountInput(),

              const SizedBox(height: 24),

              // Notes (Optional)
              _buildSectionLabel('Notes (Optional)'),
              const SizedBox(height: 12),
              _buildNotesInput(),

              const SizedBox(height: 40),

              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates a section label
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF4A4A4A),
      ),
    );
  }

  /// Creates the fixed/non-fixed budget type selector
  Widget _buildBudgetTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isFixed = true),
            child: Card(
              elevation: 0,
              color: _isFixed ? const Color(0xFF111827) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _isFixed ? Colors.transparent : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance,
                      color: _isFixed ? Colors.white : Colors.black,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fixed Expenses',
                      style: TextStyle(
                        color: _isFixed ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isFixed = false),
            child: Card(
              elevation: 0,
              color: !_isFixed ? const Color(0xFF111827) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: !_isFixed ? Colors.transparent : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.show_chart,
                      color: !_isFixed ? Colors.white : Colors.black,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Non-Fixed\nExpenses',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_isFixed ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Creates the period selector
  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _period = 'Weekly';
              _calculateWeeklyAmount();
            }),
            child: Card(
              elevation: 0,
              color:
                  _period == 'Weekly' ? const Color(0xFF111827) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _period == 'Weekly'
                      ? Colors.transparent
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _period == 'Weekly' ? Colors.white : Colors.black,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Weekly',
                      style: TextStyle(
                        color:
                            _period == 'Weekly' ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _period = 'Monthly';
              _calculateWeeklyAmount();
            }),
            child: Card(
              elevation: 0,
              color:
                  _period == 'Monthly' ? const Color(0xFF111827) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _period == 'Monthly'
                      ? Colors.transparent
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: _period == 'Monthly' ? Colors.white : Colors.black,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monthly',
                      style: TextStyle(
                        color:
                            _period == 'Monthly' ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Creates the amount input field
  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 18),
        decoration: const InputDecoration(
          hintText: '0.00',
          prefixText: '\$ ',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        ),
        onChanged: (_) => _calculateWeeklyAmount(),
      ),
    );
  }

  /// Creates the notes input field
  Widget _buildNotesInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Add notes...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  /// Creates the save button
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveBudget,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF111827),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Save Budget',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Save periodic budget to database
  Future<void> _saveBudget() async {
    // Validation

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Get current user
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    try {
      // Create a single monthly budget only
      // Get notes if provided
      final notes = _notesController.text.trim();

      // Create the monthly budget
      final budget = MonthlyBudget(
        id: '',
        userId: user.id,
        year: now.year,
        month: now.month,
        amount: amount,
        currency: 'USD', // TODO: Replace with actual currency selection if available
        notes: notes.isNotEmpty ? notes : null,
      );
      await ref.read(monthlyBudgetRepositoryProvider).addMonthlyBudget(budget);

      // Success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget saved')),
        );
        Navigator.of(context).pop(); // Return to previous screen
      }

      // Refresh monthly budget list and store result
      final res = await ref.refresh(monthlyBudgetsProvider.future);
      debugPrint('Refreshed budgets, count: ${res.length}');
    } catch (e) {
      // Error handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving budget: $e')),
        );
      }
    }
  }
}
