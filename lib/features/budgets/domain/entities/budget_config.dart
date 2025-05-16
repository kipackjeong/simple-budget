/// Represents a user's budget configuration.
class BudgetConfig {
  final String id;
  final String userId;
  final double monthlyAmount;
  final DateTime insertedAt;
  final DateTime updatedAt;

  /// Weekly amount is calculated as monthly amount / 4
  double get weeklyAmount => monthlyAmount / 4;

  BudgetConfig({
    required this.id,
    required this.userId,
    required this.monthlyAmount,
    required this.insertedAt,
    required this.updatedAt,
  });

  factory BudgetConfig.fromMap(Map<String, dynamic> map) {
    return BudgetConfig(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      monthlyAmount: (map['monthly_amount'] as num).toDouble(),
      insertedAt: DateTime.parse(map['inserted_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'monthly_amount': monthlyAmount,
      'inserted_at': insertedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
