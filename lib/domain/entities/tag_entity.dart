import 'package:flutter/material.dart';

class TagEntity {
  final int? id;
  final String name;
  final int color;
  final DateTime createdAt;

  const TagEntity({
    this.id,
    required this.name,
    this.color = 0xFF42A5F5,
    required this.createdAt,
  });

  TagEntity copyWith({
    int? id,
    String? name,
    int? color,
    DateTime? createdAt,
  }) {
    return TagEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Color get backgroundColor => Color(color);
}
