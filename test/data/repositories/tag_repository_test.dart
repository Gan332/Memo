import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/data/database/app_database.dart';
import 'package:memo_app/data/repositories/tag_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late TagRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = TagRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TagRepository', () {
    test('insertTag returns id', () async {
      final id = await repository.insertTag(TagsCompanion.insert(
        name: 'Work',
        createdAt: '2025-01-01T00:00:00',
      ));

      expect(id, isA<int>());
      expect(id, greaterThan(0));
    });

    test('getAllTags returns inserted tags', () async {
      await repository.insertTag(TagsCompanion.insert(
        name: 'Work',
        createdAt: '2025-01-01T00:00:00',
      ));
      await repository.insertTag(TagsCompanion.insert(
        name: 'Personal',
        createdAt: '2025-01-02T00:00:00',
      ));

      final tags = await repository.getAllTags();
      expect(tags.length, 2);
    });

    test('deleteTag removes tag', () async {
      final id = await repository.insertTag(TagsCompanion.insert(
        name: 'To Delete',
        createdAt: '2025-01-01T00:00:00',
      ));

      await repository.deleteTag(id);
      final tags = await repository.getAllTags();
      expect(tags.length, 0);
    });

    test('deleteTag cascades to noteTags', () async {
      final tagId = await repository.insertTag(TagsCompanion.insert(
        name: 'Cascade',
        createdAt: '2025-01-01T00:00:00',
      ));

      // Insert a note
      final noteId = await db.into(db.notes).insert(NotesCompanion.insert(
            title: Value('Note'),
            createdAt: '2025-01-01T00:00:00',
            updatedAt: '2025-01-01T00:00:00',
          ));

      // Associate tag with note
      await db.into(db.noteTags).insert(
            NoteTagsCompanion.insert(noteId: noteId, tagId: tagId),
          );

      // Delete tag
      await repository.deleteTag(tagId);

      // Verify noteTag is also deleted
      final noteTags = await (db.select(db.noteTags)
            ..where((nt) => nt.tagId.equals(tagId)))
          .get();
      expect(noteTags.length, 0);
    });

    test('getTagCount returns correct count', () async {
      await repository.insertTag(TagsCompanion.insert(
        name: 'Tag 1',
        createdAt: '2025-01-01T00:00:00',
      ));
      await repository.insertTag(TagsCompanion.insert(
        name: 'Tag 2',
        createdAt: '2025-01-02T00:00:00',
      ));

      final count = await repository.getTagCount();
      expect(count, 2);
    });
  });
}
