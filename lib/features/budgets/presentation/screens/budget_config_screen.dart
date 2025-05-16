import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/budget_config.dart';
import '../providers/budget_config_providers.dart';
import '../providers/fixed_expense_providers.dart';
import 'fixed_expenses_screen.dart';

/// Screen for managing budget configuration with a clean, minimal UI
class BudgetConfigScreen extends ConsumerStatefulWidget {
  final BudgetConfig? initialConfig;

  const BudgetConfigScreen({Key? key, this.initialConfig}) : super(key: key);

  @override
  ConsumerState<BudgetConfigScreen> createState() => _BudgetConfigScreenState();
}

class _BudgetConfigScreenState extends ConsumerState<BudgetConfigScreen> {
  /// Determines if the budget is fixed or flexible
  late bool _isFixed;

  /// Amount input controller
  final TextEditingController _amountController = TextEditingController();

  /// Notes input controller (optional)
  final TextEditingController _notesController = TextEditingController();

  /// Calculated weekly amount (always monthly/4)
  double? _weeklyAmount;
  
  // We use the totalFixedExpensesProvider directly, so no need for a local field
  
  /// Currency formatter
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    
    // Initialize with default value since type field has been removed
    _isFixed = true; // Default to fixed budget
    
    if (widget.initialConfig != null) {
      _amountController.text = 
          widget.initialConfig!.monthlyAmount.toStringAsFixed(2);
      _calculateWeeklyAmount();
    }
    
    // Load fixed expenses total
    _loadFixedExpensesTotal();
  }

  /// Calculate weekly equivalent of monthly budget
  void _calculateWeeklyAmount() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null) {
      setState(() => _weeklyAmount = amount / 4);
    } else {
      setState(() => _weeklyAmount = null);
    }
  }
  
  /// Load the total amount of fixed expenses
  Future<void> _loadFixedExpensesTotal() async {
    try {
      // Refresh the fixed expenses provider to update the UI
      final _ = await ref.refresh(totalFixedExpensesProvider.future);
      // We don't need to do anything with the result, we just want to refresh the provider
    } catch (err) {
      // Handle error silently
    }
  }
  
  /// Build a summary card showing fixed expenses information
  Widget _buildFixedExpensesSummary() {
    return ref.watch(totalFixedExpensesProvider).when(
      data: (total) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fixed Expenses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(total),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is the recommended minimum for your monthly budget.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Use fixed expenses total as amount
                    if (total > 0) {
                      setState(() {
                        _amountController.text = total.toStringAsFixed(2);
                        _calculateWeeklyAmount();
                      });
                    }
                  },
                  icon: const Icon(Icons.auto_fix_normal, size: 18),
                  label: const Text('Use as Monthly Budget'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Title based on whether we're creating or updating
    final isUpdating = widget.initialConfig != null;
    final title = isUpdating ? 'Update Budget' : 'Create Budget';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Budget Type
              _buildSectionLabel('Budget Type'),
              const SizedBox(height: 12),
              // Fixed Expenses Summary Card
              _buildFixedExpensesSummary(),
              
              _buildBudgetTypeSelector(),

              const SizedBox(height: 24),

              // Monthly Budget Amount
              _buildSectionLabel('Monthly Budget Amount'),
              const SizedBox(height: 12),
              _buildAmountInput(),

              // Show calculated weekly amount
              if (_weeklyAmount != null) ...[
                const SizedBox(height: 16),
                _buildWeeklyAmountDisplay(),
              ],

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

  /// Widget to display calculated weekly amount
  Widget _buildWeeklyAmountDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[800], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Weekly budget: \$${_weeklyAmount!.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
      onPressed: _saveBudgetConfig,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF111827),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        widget.initialConfig != null ? 'Update Budget' : 'Save Budget',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Save budget configuration to database
  Future<void> _saveBudgetConfig() async {
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
      // Notes can be stored in the future if needed
      // Currently we don't use the notes field

      if (widget.initialConfig != null) {
        // Update existing configuration
        final updatedConfig = BudgetConfig(
          id: widget.initialConfig!.id,
          userId: user.id,
          monthlyAmount: amount,
          insertedAt: widget.initialConfig!.insertedAt,
          updatedAt: now,
        );
        
        await ref
            .read(budgetConfigNotifierProvider.notifier)
            .updateBudgetConfig(updatedConfig);
      } else {
        // Create new configuration
        final newConfig = BudgetConfig(
          id: '',  // Will be filled by Supabase
          userId: user.id,
          monthlyAmount: amount,
          insertedAt: now,
          updatedAt: now,
        );
        
        await ref
            .read(budgetConfigNotifierProvider.notifier)
            .createBudgetConfig(newConfig);
      }

      // Success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget configuration saved')),
        );
        Navigator.of(context).pop(); // Return to previous screen
      }

      // Refresh budget configuration provider and log the result
      final refreshedConfig = await ref.refresh(budgetConfigProvider.future);
      debugPrint('Budget config refreshed: ${refreshedConfig != null}');
    } catch (err) {
      // Error handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving budget configuration: $err')),
        );
      }
    }
  }
}
