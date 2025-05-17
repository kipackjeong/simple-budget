/// Dart model for the 'recurring_items' table.
import 'package:meta/meta.dart';
import 'period_type.dart';
import 'entry_type.dart';

@immutable
class RecurringItem {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final PeriodType period;
  final EntryType type;
  final DateTime createdAt;

  const RecurringItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.period,
    required this.type,
    required this.createdAt,
  });

  factory RecurringItem.fromJson(Map<String, dynamic> json) => RecurringItem(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        amount: double.parse(json['amount'].toString()),
        period: PeriodTypeExtension.fromDbString(json['period'] as String),
        type: EntryTypeExtension.fromDbString(json['type'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'amount': amount,
        'period': period.toDbString(),
        'type': type.toDbString(),
        'created_at': createdAt.toIso8601String(),
      };
}
