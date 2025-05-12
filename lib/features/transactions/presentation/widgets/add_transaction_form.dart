import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_tracker/shared/themes/app_theme.dart';
import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';

/// A form widget for adding a new transaction
class AddTransactionForm extends StatefulWidget {
  final void Function(Transaction) onSubmit;
  const AddTransactionForm({Key? key, required this.onSubmit})
      : super(key: key);

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  // false = Expense, true = Income
  bool _isIncome = false;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TransactionCategory _selectedCategory = TransactionCategory.Other;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null) return;
    final amount = _isIncome ? enteredAmount.abs() : -enteredAmount.abs();
    final transaction = Transaction(
      id: null, // Will be set by Supabase
      userId: null,
      title: _titleController.text.trim(),
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    widget.onSubmit(transaction);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Title required' : null,
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v == null || double.tryParse(v) == null
                      ? 'Valid amount required'
                      : null,
                ),
                Row(
                  children: [
                    // Transaction type selector
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Text(
                              'Expense',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: !_isIncome
                                    ? theme.colorScheme.onPrimary
                                    : AppTheme.expenseColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: !_isIncome,
                            selectedColor: AppTheme.expenseColor,
                            backgroundColor:
                                AppTheme.expenseColor.withOpacity(0.1),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _isIncome = false);
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: Text(
                              'Income',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: _isIncome
                                    ? theme.colorScheme.onPrimary
                                    : AppTheme.incomeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: _isIncome,
                            selectedColor: AppTheme.incomeColor,
                            backgroundColor:
                                AppTheme.incomeColor.withOpacity(0.1),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _isIncome = true);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      child: Text(
                        'Pick Date',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                DropdownButtonFormField<TransactionCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: TransactionCategory.values
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat.name),
                          ))
                      .toList(),
                  onChanged: (cat) {
                    if (cat != null) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                ),
                TextFormField(
                  controller: _notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add Transaction',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
