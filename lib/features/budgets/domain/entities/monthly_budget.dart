import 'package:meta/meta.dart';

/// Represents the overall monthly budget for a user for a specific year and month.
@immutable
class MonthlyBudget {
  final String id;
  final String userId;
  final int year;
  final int month;
  final double amount;
  final String currency;
  /// Optional notes for this budget
  final String? notes;

  const MonthlyBudget({
    required this.id,
    required this.userId,
    required this.year,
    required this.month,
    required this.amount,
    required this.currency,
    this.notes,
  });

  factory MonthlyBudget.fromMap(Map<String, dynamic> map) {
    return MonthlyBudget(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      year: map['year'] as int,
      month: map['month'] as int,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'year': year,
      'month': month,
      'amount': amount,
      'currency': currency,
      if (notes != null) 'notes': notes,
    };
  }
}
