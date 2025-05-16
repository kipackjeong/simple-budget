import 'package:meta/meta.dart';

/// Represents a fixed recurring expense that contributes to the user's budget.
@immutable
class FixedExpense {
  /// Unique identifier for the expense
  final String id;
  
  /// ID of the user who owns this expense
  final String userId;
  
  /// Name of the expense (e.g., "Rent", "Netflix")
  final String title;
  
  /// Monthly amount of the expense
  final double amount;
  
  /// Category of the expense (e.g., "Housing", "Entertainment")
  final String category;
  
  /// How often the expense occurs: 'monthly', 'quarterly', 'annual'
  final String frequency;
  
  /// Next due date for the expense
  final DateTime dueDate;
  
  /// When the expense record was created
  final DateTime insertedAt;
  
  /// When the expense record was last updated
  final DateTime updatedAt;

  /// Constructor for FixedExpense
  const FixedExpense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.dueDate,
    required this.insertedAt,
    required this.updatedAt,
  });

  /// Creates a FixedExpense from a map (usually from database)
  factory FixedExpense.fromMap(Map<String, dynamic> map) {
    return FixedExpense(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      frequency: map['frequency'] as String,
      dueDate: DateTime.parse(map['due_date'] as String),
      insertedAt: DateTime.parse(map['inserted_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Converts the FixedExpense to a map (usually for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'due_date': dueDate.toIso8601String(),
      'inserted_at': insertedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
