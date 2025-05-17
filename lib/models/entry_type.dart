/// Enum for entry_type as defined in the database schema.
/// Values: 'income', 'expense'

enum EntryType {
  income,
  expense,
}

extension EntryTypeExtension on EntryType {
  String toDbString() {
    switch (this) {
      case EntryType.income:
        return 'income';
      case EntryType.expense:
        return 'expense';
    }
  }

  static EntryType fromDbString(String value) {
    switch (value) {
      case 'income':
        return EntryType.income;
      case 'expense':
        return EntryType.expense;
      default:
        throw ArgumentError('Unknown entry_type: $value');
    }
  }
}
