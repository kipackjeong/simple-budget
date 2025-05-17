/// Dart model for the 'users' table.
import 'package:meta/meta.dart';

@immutable
class User {
  final String id;
  final String email;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'created_at': createdAt.toIso8601String(),
      };
}
