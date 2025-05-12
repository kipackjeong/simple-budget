import 'package:equatable/equatable.dart';

/// Transaction categories
enum TransactionCategory {
  /// Shopping category
  Shopping,

  /// Restaurant/Food category
  Restaurant,

  /// Income/Salary category
  Salary,

  /// Bills category
  Bills,

  /// Transportation category
  Transportation,

  /// Entertainment category
  Entertainment,

  /// Other expenses category
  Other
}

/// Extension on TransactionCategory for better handling
extension TransactionCategoryExtension on TransactionCategory {
  /// Get the string representation of the category
  String get name {
    switch (this) {
      case TransactionCategory.Shopping:
        return 'Shopping';
      case TransactionCategory.Restaurant:
        return 'Restaurant';
      case TransactionCategory.Salary:
        return 'Salary';
      case TransactionCategory.Bills:
        return 'Bills';
      case TransactionCategory.Transportation:
        return 'Transportation';
      case TransactionCategory.Entertainment:
        return 'Entertainment';
      case TransactionCategory.Other:
        return 'Other';
    }
  }

  /// Get the icon data for the category
  String get iconName {
    switch (this) {
      case TransactionCategory.Shopping:
        return 'shopping_bag';
      case TransactionCategory.Restaurant:
        return 'restaurant';
      case TransactionCategory.Salary:
        return 'account_balance';
      case TransactionCategory.Bills:
        return 'receipt';
      case TransactionCategory.Transportation:
        return 'directions_car';
      case TransactionCategory.Entertainment:
        return 'movie';
      case TransactionCategory.Other:
        return 'category';
    }
  }
}

/// Transaction model representing financial transactions
class Transaction extends Equatable {
  /// Unique identifier for the transaction
  final String? id;

  /// User ID associated with the transaction
  final String? userId;

  /// Transaction title or merchant name
  final String title;

  /// Transaction amount (positive for income, negative for expenses)
  final double amount;

  /// Date and time of the transaction
  final DateTime date;

  /// Category of the transaction
  final TransactionCategory category;

  /// Additional notes about the transaction
  final String? notes;

  /// Creates a transaction instance
  const Transaction({
    this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
  });

  /// Creates a copy of this transaction with specified changes
  Transaction copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? date,
    TransactionCategory? category,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  /// Creates a transaction from a map (for database operations)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'], // nullable id for backend-generated IDs
      userId: map['user_id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      category: TransactionCategory.values.byName(map['category']),
      notes: map['notes'],
    );
  }

  /// Converts this transaction to a map (for database operations)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
      'notes': notes,
    };
    if (id != null) map['id'] = id;
    if (userId != null) map['user_id'] = userId;
    return map;
  }

  /// Determines if the transaction is an expense
  bool get isExpense => amount < 0;

  /// Determines if the transaction is income
  bool get isIncome => amount >= 0;

  @override
  List<Object?> get props => [id, userId, title, amount, date, category, notes];
}
