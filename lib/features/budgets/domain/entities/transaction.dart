import 'package:meta/meta.dart';

/// Represents a single financial transaction for a user.
@immutable
class Transaction {
  final String id;
  final String userId;
  final DateTime date;
  final String type; // 'Income' or 'Expense'
  final String name;
  final String categoryId;
  final double amount;
  final String notes;

  const Transaction({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.name,
    required this.categoryId,
    required this.amount,
    required this.notes,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      name: map['name'] as String,
      categoryId: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'type': type,
      'name': name,
      'category': categoryId,
      'amount': amount,
      'notes': notes,
    };
  }
}
