import 'package:flutter/material.dart';

import '../../utils/date_formatter.dart';

enum NoteType { text, checklist }

class NoteEntity {
  final int? id;
  final String title;
  final String content;
  final NoteType noteType;
  final int color;
  final bool isPinned;
  final bool isArchived;
  final bool isDeleted;
  final DateTime? deletedAt;
  final int? reminderTimestamp;
  final bool? reminderFired;
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
    this.isDeleted = false,
    this.deletedAt,
    this.reminderTimestamp,
    this.reminderFired,
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
    bool? isDeleted,
    DateTime? deletedAt,
    int? reminderTimestamp,
    bool? reminderFired,
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
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      reminderTimestamp: reminderTimestamp ?? this.reminderTimestamp,
      reminderFired: reminderFired ?? this.reminderFired,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get preview {
    final text = content.replaceAll(RegExp(r'\s+'), ' ');
    return text.length > 80 ? '${text.substring(0, 80)}...' : text;
  }

  String get formattedDate => formatRelativeDate(updatedAt);

  Color get backgroundColor => Color(color);
}
