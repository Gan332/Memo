import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/data/database/app_database.dart';
import 'package:memo_app/data/repositories/note_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late NoteRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = NoteRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('NoteRepository', () {
    test('insertNote returns id', () async {
      final id = await repository.insertNote(NotesCompanion.insert(
        title: Value('Test Note'),
        content: Value('Content'),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));

      expect(id, isA<int>());
      expect(id, greaterThan(0));
    });

    test('getNotes returns inserted notes', () async {
      await repository.insertNote(NotesCompanion.insert(
        title: Value('Note 1'),
        content: Value('Content 1'),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));
      await repository.insertNote(NotesCompanion.insert(
        title: Value('Note 2'),
        content: Value('Content 2'),
        createdAt: '2025-01-02T00:00:00',
        updatedAt: '2025-01-02T00:00:00',
      ));

      final notes = await repository.getNotes();
      expect(notes.length, 2);
    });

    test('getNotes filters by searchQuery', () async {
      await repository.insertNote(NotesCompanion.insert(
        title: Value('Flutter'),
        content: Value('Content'),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));
      await repository.insertNote(NotesCompanion.insert(
        title: Value('Dart'),
        content: Value('Content'),
        createdAt: '2025-01-02T00:00:00',
        updatedAt: '2025-01-02T00:00:00',
      ));

      final notes = await repository.getNotes(searchQuery: 'Flutter');
      expect(notes.length, 1);
      expect(notes.first.note.title, 'Flutter');
    });

    test('getNotes filters by isArchived', () async {
      await repository.insertNote(NotesCompanion.insert(
        title: Value('Active'),
        content: Value(''),
        isArchived: const Value(false),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));
      await repository.insertNote(NotesCompanion.insert(
        title: Value('Archived'),
        content: Value(''),
        isArchived: const Value(true),
        createdAt: '2025-01-02T00:00:00',
        updatedAt: '2025-01-02T00:00:00',
      ));

      final active = await repository.getNotes(isArchived: false);
      expect(active.length, 1);
      expect(active.first.note.title, 'Active');

      final archived = await repository.getNotes(isArchived: true);
      expect(archived.length, 1);
      expect(archived.first.note.title, 'Archived');
    });

    test('getNotes filters by hasReminder', () async {
      await repository.insertNote(NotesCompanion.insert(
        title: Value('With Reminder'),
        content: Value(''),
        reminderTimestamp: const Value(1800000000),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));
      await repository.insertNote(NotesCompanion.insert(
        title: Value('No Reminder'),
        content: Value(''),
        createdAt: '2025-01-02T00:00:00',
        updatedAt: '2025-01-02T00:00:00',
      ));

      final withReminder = await repository.getNotes(hasReminder: true);
      expect(withReminder.length, 1);
      expect(withReminder.first.note.title, 'With Reminder');

      final withoutReminder = await repository.getNotes(hasReminder: false);
      expect(withoutReminder.length, 1);
      expect(withoutReminder.first.note.title, 'No Reminder');
    });

    test('togglePin changes pin status', () async {
      final id = await repository.insertNote(NotesCompanion.insert(
        title: Value('Pinned'),
        content: Value(''),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));

      await repository.togglePin(id, false);
      final pinned = await repository.getNotes(isPinned: true);
      expect(pinned.length, 1);

      await repository.togglePin(id, true);
      final unpinned = await repository.getNotes(isPinned: false);
      expect(unpinned.length, 1);
    });

    test('toggleArchive changes archive status', () async {
      final id = await repository.insertNote(NotesCompanion.insert(
        title: Value('Archived'),
        content: Value(''),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));

      await repository.toggleArchive(id, false);
      final archived = await repository.getNotes(isArchived: true);
      expect(archived.length, 1);

      await repository.toggleArchive(id, true);
      final active = await repository.getNotes(isArchived: false);
      expect(active.length, 1);
    });

    test('deleteNote removes note', () async {
      final id = await repository.insertNote(NotesCompanion.insert(
        title: Value('To Delete'),
        content: Value(''),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));

      await repository.deleteNote(id);
      final notes = await repository.getNotes();
      expect(notes.length, 0);
    });

    test('getNoteCount returns correct count', () async {
      await repository.insertNote(NotesCompanion.insert(
        title: Value('Note 1'),
        content: Value(''),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));
      await repository.insertNote(NotesCompanion.insert(
        title: Value('Note 2'),
        content: Value(''),
        isArchived: const Value(true),
        createdAt: '2025-01-02T00:00:00',
        updatedAt: '2025-01-02T00:00:00',
      ));

      final totalCount = await repository.getNoteCount();
      expect(totalCount, 2);

      final archivedCount = await repository.getNoteCount(isArchived: true);
      expect(archivedCount, 1);
    });

    test('getStats aggregates note statistics', () async {
      await repository.insertNote(NotesCompanion.insert(
        title: Value('Active Pinned'),
        content: Value('hello world'),
        isPinned: const Value(true),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));
      await repository.insertNote(NotesCompanion.insert(
        title: Value('Checklist'),
        content: Value(''),
        noteType: const Value('checklist'),
        isArchived: const Value(true),
        createdAt: '2025-01-02T00:00:00',
        updatedAt: '2025-01-02T00:00:00',
      ));

      final stats = await repository.getStats();

      expect(stats.totalCount, 2);
      expect(stats.activeCount, 1);
      expect(stats.archivedCount, 1);
      expect(stats.trashedCount, 0);
      expect(stats.pinnedCount, 1);
      expect(stats.checklistCount, 1);
      expect(stats.textCount, 1);
      expect(stats.totalWords, 2);
      expect(stats.totalChars, 11);
      expect(stats.createdByDay.length, 7);
    });

    test('duplicateNote copies note with tags and checklist items', () async {
      final tagId = await db.into(db.tags).insert(
            TagsCompanion.insert(
              name: 'Work',
              color: const Value(0xFF66BB6A),
              createdAt: '2025-01-01T00:00:00',
            ),
          );
      final noteId = await repository.insertNote(NotesCompanion.insert(
        title: Value('Original'),
        content: Value('# hello'),
        noteType: const Value('checklist'),
        isPinned: const Value(true),
        isArchived: const Value(true),
        reminderTimestamp: const Value(1800000000),
        reminderFired: const Value(false),
        createdAt: '2025-01-01T00:00:00',
        updatedAt: '2025-01-01T00:00:00',
      ));
      await db.into(db.noteTags).insert(
            NoteTagsCompanion.insert(noteId: noteId, tagId: tagId),
          );
      await db.into(db.checklistItems).insert(
            ChecklistItemsCompanion.insert(
              noteId: noteId,
              itemText: 'item one',
              isCompleted: const Value(true),
              sortOrder: const Value(0),
            ),
          );

      final newId = await repository.duplicateNote(noteId);

      expect(newId, isNot(noteId));
      final copy = await repository.getNote(newId);
      expect(copy, isNotNull);
      expect(copy!.note.title, 'Original');
      expect(copy.note.content, '# hello');
      expect(copy.note.noteType, 'checklist');
      expect(copy.note.isPinned, true);
      expect(copy.note.isArchived, true);
      expect(copy.note.isDeleted, false);
      expect(copy.note.reminderTimestamp, isNull);
      expect(copy.note.reminderFired, isNull);
      expect(copy.note.createdAt, isNot('2025-01-01T00:00:00'));
      expect(copy.tags.map((t) => t.name), contains('Work'));

      final items = await repository.getChecklistItems(newId);
      expect(items.length, 1);
      expect(items.first.itemText, 'item one');
      expect(items.first.isCompleted, true);
      expect(items.first.sortOrder, 0);
    });

    test('duplicateNote throws when note does not exist', () async {
      expect(
        () => repository.duplicateNote(9999),
        throwsA(isA<StateError>()),
      );
    });
  });
}
