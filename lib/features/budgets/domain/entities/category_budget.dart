import 'package:meta/meta.dart';

/// Represents a category-specific budget for a user for a specific year and month.
@immutable
class CategoryBudget {
  final String id;
  final String userId;
  final int year;
  final int month;
  final double amount;
  final String categoryId;
  final String currency;

  const CategoryBudget({
    required this.id,
    required this.userId,
    required this.year,
    required this.month,
    required this.amount,
    required this.categoryId,
    required this.currency,
  });

  factory CategoryBudget.fromMap(Map<String, dynamic> map) {
    return CategoryBudget(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      year: map['year'] as int,
      month: map['month'] as int,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category'] as String,
      currency: map['currency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'year': year,
      'month': month,
      'amount': amount,
      'category': categoryId,
      'currency': currency,
    };
  }
}
