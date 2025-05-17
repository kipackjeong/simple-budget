/// Enum for period_type as defined in the database schema.
/// Values: 'weekly', 'biweekly', 'monthly', 'yearly'

enum PeriodType {
  weekly,
  biweekly,
  monthly,
  yearly,
}

extension PeriodTypeExtension on PeriodType {
  String toDbString() {
    switch (this) {
      case PeriodType.weekly:
        return 'weekly';
      case PeriodType.biweekly:
        return 'biweekly';
      case PeriodType.monthly:
        return 'monthly';
      case PeriodType.yearly:
        return 'yearly';
    }
  }

  static PeriodType fromDbString(String value) {
    switch (value) {
      case 'weekly':
        return PeriodType.weekly;
      case 'biweekly':
        return PeriodType.biweekly;
      case 'monthly':
        return PeriodType.monthly;
      case 'yearly':
        return PeriodType.yearly;
      default:
        throw ArgumentError('Unknown period_type: $value');
    }
  }
}
