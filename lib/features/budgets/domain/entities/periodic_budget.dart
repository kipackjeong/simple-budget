/// Represents a periodic budget entry
class PeriodicBudget {
  final String id;
  final String userId;
  final String type; // 'fixed' or 'non-fixed'
  final String period; // 'Weekly' or 'Monthly'
  final double amount;
  final DateTime insertedAt;
  final DateTime updatedAt;

  PeriodicBudget({
    required this.id,
    required this.userId,
    required this.type,
    required this.period,
    required this.amount,
    required this.insertedAt,
    required this.updatedAt,
  });

  factory PeriodicBudget.fromMap(Map<String, dynamic> map) {
    return PeriodicBudget(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: map['type'] as String,
      period: map['period'] as String,
      amount: (map['amount'] as num).toDouble(),
      insertedAt: DateTime.parse(map['inserted_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'period': period,
      'amount': amount,
      'inserted_at': insertedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
