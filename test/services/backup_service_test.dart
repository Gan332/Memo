import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/services/backup_service.dart';
import 'package:memo_app/data/database/app_database.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late BackupService service;

  setUp(() async {
    db = createTestDatabase();
    service = BackupService(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupService', () {
    test('exportBackup returns valid JSON', () async {
      // Add some data
      await db.into(db.notes).insert(NotesCompanion.insert(
            title: Value('Test Note'),
            content: Value('Content'),
            createdAt: '2025-01-01T00:00:00',
            updatedAt: '2025-01-01T00:00:00',
          ));
      await db.into(db.tags).insert(TagsCompanion.insert(
            name: 'Work',
            createdAt: '2025-01-01T00:00:00',
          ));

      final json = await service.exportBackup();
      expect(json, isA<String>());
      expect(json.contains('schemaVersion'), true);
      expect(json.contains('notes'), true);
      expect(json.contains('tags'), true);
    });

    test('importBackup restores notes', () async {
      // Create backup data
      final now = DateTime.now();
      final noteId = await db.into(db.notes).insert(NotesCompanion.insert(
            title: Value('Original'),
            content: Value('Content'),
            createdAt: now.toIso8601String(),
            updatedAt: now.toIso8601String(),
          ));

      final json = await service.exportBackup();

      // Clear database
      await db.delete(db.notes).go();
      await db.delete(db.tags).go();

      // Import
      final metadata = await service.importBackup(json);
      expect(metadata.addedCount, 1);

      // Verify
      final notes = await db.select(db.notes).get();
      expect(notes.length, 1);
      expect(notes.first.title, 'Original');
    });

    test('importBackup handles duplicate notes', () async {
      final now = DateTime.now();

      // Insert a note
      await db.into(db.notes).insert(NotesCompanion.insert(
            title: Value('Existing'),
            content: Value('Old Content'),
            createdAt: now.toIso8601String(),
            updatedAt: now.toIso8601String(),
          ));

      // Create backup with updated note
      final backupNote = (await db.select(db.notes).get()).first;
      final backupData = BackupData(
        schemaVersion: 1,
        exportedAt: now,
        notes: [backupNote],
        tags: [],
        noteTags: [],
        checklistItems: [],
      );

      final json = backupData.toJsonString();

      // Import
      final metadata = await service.importBackup(json);
      expect(metadata.updatedCount, 1);

      // Verify content was updated
      final notes = await db.select(db.notes).get();
      expect(notes.length, 1);
      expect(notes.first.content, 'Old Content');
    });

    test('importBackup restores tags', () async {
      final now = DateTime.now();
      final tagId = await db.into(db.tags).insert(TagsCompanion.insert(
            name: 'Work',
            createdAt: now.toIso8601String(),
          ));

      final json = await service.exportBackup();

      // Clear
      await db.delete(db.notes).go();
      await db.delete(db.tags).go();

      // Import
      final metadata = await service.importBackup(json);
      expect(metadata.tagCount, 1);

      final tags = await db.select(db.tags).get();
      expect(tags.length, 1);
      expect(tags.first.name, 'Work');
    });
  });
}
