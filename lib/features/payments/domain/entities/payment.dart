import 'package:equatable/equatable.dart';

/// Payment status enum
enum PaymentStatus {
  /// Payment is pending
  pending,
  
  /// Payment was successful
  successful,
  
  /// Payment failed
  failed,
  
  /// Payment was cancelled
  cancelled
}

/// Payment method enum
enum PaymentMethod {
  /// Apple Pay
  applePay,
  
  /// Credit Card
  creditCard,
  
  /// Bank Transfer
  bankTransfer
}

/// Payment model representing a payment transaction
class Payment extends Equatable {
  /// Unique identifier for the payment
  final String id;
  
  /// Amount of the payment
  final double amount;
  
  /// Currency of the payment
  final String currency;
  
  /// Date and time when the payment was initiated
  final DateTime date;
  
  /// Status of the payment
  final PaymentStatus status;
  
  /// Payment method used
  final PaymentMethod method;
  
  /// Transaction ID associated with the payment (if any)
  final String? transactionId;
  
  /// Additional metadata about the payment
  final Map<String, dynamic>? metadata;

  /// Creates a payment instance
  const Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.date,
    required this.status,
    required this.method,
    this.transactionId,
    this.metadata,
  });

  /// Creates a copy of this payment with specified changes
  Payment copyWith({
    String? id,
    double? amount,
    String? currency,
    DateTime? date,
    PaymentStatus? status,
    PaymentMethod? method,
    String? transactionId,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      status: status ?? this.status,
      method: method ?? this.method,
      transactionId: transactionId ?? this.transactionId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Creates a payment from a map (for database operations)
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      amount: map['amount'],
      currency: map['currency'],
      date: DateTime.parse(map['date']),
      status: PaymentStatus.values.byName(map['status']),
      method: PaymentMethod.values.byName(map['method']),
      transactionId: map['transactionId'],
      metadata: map['metadata'],
    );
  }

  /// Converts this payment to a map (for database operations)
  Map<String, dynamic> toMap() {
    final res = {
      'id': id,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'status': status.name,
      'method': method.name,
      'transactionId': transactionId,
      'metadata': metadata,
    };
    return res;
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        currency,
        date,
        status,
        method,
        transactionId,
        metadata,
      ];
}
