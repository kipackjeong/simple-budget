import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/fixed_expense.dart';
import '../providers/fixed_expense_providers.dart';
import '../widgets/fixed_expense_list_item.dart';

/// Screen for managing fixed expenses.
class FixedExpensesScreen extends ConsumerStatefulWidget {
  const FixedExpensesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FixedExpensesScreen> createState() =>
      _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends ConsumerState<FixedExpensesScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _dueDate = DateTime.now();
  String _frequency = 'monthly';
  bool _isEditing = false;
  String? _editingId;

  final List<String> _frequencyOptions = ['monthly', 'quarterly', 'annual'];
  final List<String> _categoryOptions = [
    'Housing',
    'Utilities',
    'Transportation',
    'Insurance',
    'Subscriptions',
    'Loans',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    _amountController.clear();
    _categoryController.text = _categoryOptions.first;
    _dueDate = DateTime.now();
    _frequency = 'monthly';
    _isEditing = false;
    _editingId = null;
  }

  void _showAddExpenseModal({FixedExpense? expense}) {
    // If we're editing, populate the form with existing data
    if (expense != null) {
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toString();
      _categoryController.text = expense.category;
      _dueDate = expense.dueDate;
      _frequency = expense.frequency;
      _isEditing = true;
      _editingId = expense.id;
    } else {
      _resetForm();
      _categoryController.text = _categoryOptions.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Edit Fixed Expense' : 'Add New Fixed Expense',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoryController.text.isNotEmpty
                    ? _categoryController.text
                    : _categoryOptions.first,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categoryOptions.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _categoryController.text = value;
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: _frequencyOptions.map((String frequency) {
                  return DropdownMenuItem<String>(
                    value: frequency,
                    child: Text(
                      frequency[0].toUpperCase() + frequency.substring(1),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _frequency = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && picked != _dueDate) {
                    setState(() {
                      _dueDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Next Due Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM d, yyyy').format(_dueDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveFixedExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_isEditing ? 'Update Expense' : 'Add Expense'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveFixedExpense() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final title = _titleController.text;
    final amount = double.parse(_amountController.text);
    final category = _categoryController.text;
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add expenses')),
      );
      return;
    }

    final now = DateTime.now();

    try {
      if (_isEditing && _editingId != null) {
        // Update existing expense
        final updatedExpense = FixedExpense(
          id: _editingId!,
          userId: user.id,
          title: title,
          amount: amount,
          category: category,
          frequency: _frequency,
          dueDate: _dueDate,
          insertedAt: now, // This should be the original insertedAt time
          updatedAt: now,
        );

        await ref
            .read(fixedExpenseNotifierProvider.notifier)
            .updateFixedExpense(updatedExpense);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fixed expense updated')),
        );
      } else {
        // Add new expense
        final newExpense = FixedExpense(
          id: '', // Will be filled by Supabase
          userId: user.id,
          title: title,
          amount: amount,
          category: category,
          frequency: _frequency,
          dueDate: _dueDate,
          insertedAt: now,
          updatedAt: now,
        );

        await ref
            .read(fixedExpenseNotifierProvider.notifier)
            .addFixedExpense(newExpense);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fixed expense added')),
        );
      }

      Navigator.of(context).pop();
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $err')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(fixedExpenseNotifierProvider);
    final totalAmount = ref.watch(totalFixedExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixed Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(fixedExpenseNotifierProvider.notifier)
                  .loadFixedExpenses();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Fixed Expenses',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'These expenses contribute to your budget minimum',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  totalAmount.when(
                    data: (total) => Text(
                      NumberFormat.currency(symbol: '\$').format(total),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('\$0.00'),
                  ),
                ],
              ),
            ),
          ),

          // Expense List
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No fixed expenses yet',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your recurring expenses',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return FixedExpenseListItem(
                      expense: expense,
                      onEdit: () => _showAddExpenseModal(expense: expense),
                      onDelete: () async {
                        try {
                          await ref
                              .read(fixedExpenseNotifierProvider.notifier)
                              .deleteFixedExpense(expense.id);

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Fixed expense deleted')),
                          );
                        } catch (err) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $err')),
                          );
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseModal(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
