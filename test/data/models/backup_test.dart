import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/data/models/backup.dart';
import 'package:memo_app/data/database/app_database.dart';

void main() {
  group('BackupData', () {
    test('should serialize and deserialize correctly', () {
      final backup = BackupData(
        schemaVersion: 1,
        exportedAt: DateTime(2025, 1, 15, 10, 30),
        notes: [
          NoteRow(
            id: 1,
            title: 'Test Note',
            content: 'Content',
            noteType: 'text',
            color: 0xFFFEF7E0,
            isPinned: true,
            isArchived: false,
            isDeleted: false,
            createdAt: '2025-01-15T10:00:00.000',
            updatedAt: '2025-01-15T10:30:00.000',
          ),
        ],
        tags: [
          Tag(
            id: 1,
            name: 'important',
            color: 0xFF42A5F5,
            createdAt: '2025-01-15T10:00:00.000',
          ),
        ],
        noteTags: [
          NoteTag(noteId: 1, tagId: 1),
        ],
        checklistItems: [
          ChecklistItem(
            id: 1,
            noteId: 1,
            itemText: 'Buy milk',
            isCompleted: false,
            sortOrder: 0,
          ),
        ],
      );

      final json = backup.toJsonString();
      final restored = BackupData.fromJsonString(json);

      expect(restored.schemaVersion, 1);
      expect(restored.notes.length, 1);
      expect(restored.notes[0].title, 'Test Note');
      expect(restored.tags.length, 1);
      expect(restored.tags[0].name, 'important');
      expect(restored.noteTags.length, 1);
      expect(restored.checklistItems.length, 1);
      expect(restored.checklistItems[0].itemText, 'Buy milk');
    });

    test('should handle empty backup', () {
      final backup = BackupData(
        schemaVersion: 1,
        exportedAt: DateTime.now(),
        notes: [],
        tags: [],
        noteTags: [],
        checklistItems: [],
      );

      final json = backup.toJsonString();
      final restored = BackupData.fromJsonString(json);

      expect(restored.notes, isEmpty);
      expect(restored.tags, isEmpty);
      expect(restored.noteTags, isEmpty);
      expect(restored.checklistItems, isEmpty);
    });
  });
}
