import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/state/providers/tag_provider.dart';
import 'package:memo_app/data/database/app_database.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late TagProvider provider;

  setUp(() async {
    db = createTestDatabase();
    provider = TagProvider(db: db);
    await provider.loadTags();
  });

  tearDown(() async {
    provider.dispose();
    await db.close();
  });

  group('TagProvider', () {
    test('initial state is empty tags list', () {
      expect(provider.tags, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, '');
    });

    test('addTag adds tag to list', () async {
      await provider.addTag('Work');
      expect(provider.tags.length, 1);
      expect(provider.tags.first.name, 'Work');
    });

    test('addTag with color stores color', () async {
      await provider.addTag('Personal', color: 0xFF66BB6A);
      expect(provider.tags.length, 1);
      expect(provider.tags.first.color, 0xFF66BB6A);
    });

    test('updateTag updates tag name', () async {
      await provider.addTag('Old Name');
      final tag = provider.tags.first;

      await provider.updateTag(tag.copyWith(name: 'New Name'));
      expect(provider.tags.first.name, 'New Name');
    });

    test('deleteTag removes tag', () async {
      await provider.addTag('To Delete');
      final tag = provider.tags.first;

      await provider.deleteTag(tag.id!);
      expect(provider.tags.length, 0);
    });

    test('addTagToNote creates association', () async {
      // Insert a note
      final noteId = await db.into(db.notes).insert(
            const NotesCompanion.insert(
              title: Value('Note'),
              createdAt: '2025-01-01T00:00:00',
              updatedAt: '2025-01-01T00:00:00',
            ),
          );

      await provider.addTag('Tag');
      final tagId = provider.tags.first.id!;

      await provider.addTagToNote(noteId, tagId);

      final tagIds = await provider.getTagIdsForNote(noteId);
      expect(tagIds, contains(tagId));
    });

    test('removeTagFromNote removes association', () async {
      // Insert a note
      final noteId = await db.into(db.notes).insert(
            const NotesCompanion.insert(
              title: Value('Note'),
              createdAt: '2025-01-01T00:00:00',
              updatedAt: '2025-01-01T00:00:00',
            ),
          );

      await provider.addTag('Tag');
      final tagId = provider.tags.first.id!;

      await provider.addTagToNote(noteId, tagId);
      await provider.removeTagFromNote(noteId, tagId);

      final tagIds = await provider.getTagIdsForNote(noteId);
      expect(tagIds, isEmpty);
    });

    test('getTagIdsForNote returns correct ids', () async {
      // Insert a note
      final noteId = await db.into(db.notes).insert(
            const NotesCompanion.insert(
              title: Value('Note'),
              createdAt: '2025-01-01T00:00:00',
              updatedAt: '2025-01-01T00:00:00',
            ),
          );

      await provider.addTag('Tag 1');
      final tag1Id = provider.tags.first.id!;

      await provider.addTag('Tag 2');
      final tag2Id = provider.tags[1].id!;

      await provider.addTagToNote(noteId, tag1Id);
      await provider.addTagToNote(noteId, tag2Id);

      final tagIds = await provider.getTagIdsForNote(noteId);
      expect(tagIds.length, 2);
      expect(tagIds, containsAll([tag1Id, tag2Id]));
    });
  });
}
