import 'package:flutter/material.dart';

enum NoteType { text, checklist }

class NoteEntity {
  final int? id;
  final String title;
  final String content;
  final NoteType noteType;
  final int color;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteEntity({
    this.id,
    required this.title,
    required this.content,
    this.noteType = NoteType.text,
    this.color = 0xFFFEF7E0,
    this.isPinned = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteEntity copyWith({
    int? id,
    String? title,
    String? content,
    NoteType? noteType,
    int? color,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      noteType: noteType ?? this.noteType,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get preview {
    final text = content.replaceAll(RegExp(r'\s+'), ' ');
    return text.length > 80 ? '${text.substring(0, 80)}...' : text;
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';

    return '${updatedAt.month}/${updatedAt.day}';
  }

  Color get backgroundColor => Color(color);
}
