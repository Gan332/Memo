import 'dart:convert';

import '../database/app_database.dart';

class BackupData {
  final int schemaVersion;
  final DateTime exportedAt;
  final List<NoteRow> notes;
  final List<Tag> tags;
  final List<NoteTag> noteTags;
  final List<ChecklistItem> checklistItems;

  BackupData({
    required this.schemaVersion,
    required this.exportedAt,
    required this.notes,
    required this.tags,
    required this.noteTags,
    required this.checklistItems,
  });

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      schemaVersion: json['schemaVersion'] as int,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      notes: (json['notes'] as List)
          .map((e) => NoteRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List)
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
      noteTags: (json['noteTags'] as List)
          .map((e) => NoteTag.fromJson(e as Map<String, dynamic>))
          .toList(),
      checklistItems: (json['checklistItems'] as List)
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'notes': notes.map((e) => e.toJson()).toList(),
        'tags': tags.map((e) => e.toJson()).toList(),
        'noteTags': noteTags.map((e) => e.toJson()).toList(),
        'checklistItems': checklistItems.map((e) => e.toJson()).toList(),
      };

  String toJsonString() => jsonEncode(toJson());

  static BackupData fromJsonString(String source) =>
      BackupData.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

class BackupMetadata {
  final int noteCount;
  final int tagCount;
  final int checklistItemCount;
  final int addedCount;
  final int updatedCount;
  final int skippedCount;
  final int failedCount;

  const BackupMetadata({
    required this.noteCount,
    required this.tagCount,
    required this.checklistItemCount,
    required this.addedCount,
    required this.updatedCount,
    required this.skippedCount,
    required this.failedCount,
  });
}
