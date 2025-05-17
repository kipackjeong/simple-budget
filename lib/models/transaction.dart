/// Dart model for the 'transactions' table.
import 'package:meta/meta.dart';

@immutable
class Transaction {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final DateTime transactionDate;
  final String description;
  final bool isRecurring;
  final String? recurringItemId;
  final Map<String, dynamic>? category; // Join data from categories table

  const Transaction({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.transactionDate,
    this.description = '',
    this.isRecurring = false,
    this.recurringItemId,
    this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      amount: double.parse(json['amount'].toString()),
      transactionDate: DateTime.parse(json['transaction_date']),
      description: json['description'] as String? ?? '',
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringItemId: json['recurring_item_id'] as String?,
      category: json['categories'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
      'description': description,
      'is_recurring': isRecurring,
      if (recurringItemId != null) 'recurring_item_id': recurringItemId,
    };
  }

  /// Whether this transaction is an income (positive amount)
  bool get isIncome => amount >= 0;
  
  /// Whether this transaction is an expense (negative amount)
  bool get isExpense => amount < 0;
  
  /// Get the category name if available
  String get categoryName => category?['name'] as String? ?? 'Uncategorized';
}
