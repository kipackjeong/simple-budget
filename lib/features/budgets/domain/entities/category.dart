import 'package:meta/meta.dart';

/// Represents a spending or income category.
@immutable
class Category {
  final String id;
  final String icon;
  final String name;
  final String? parentId;

  const Category({
    required this.id,
    required this.icon,
    required this.name,
    this.parentId,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      icon: map['icon'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      if (parentId != null) 'parent_id': parentId,
    };
  }
}
