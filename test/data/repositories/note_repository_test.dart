import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/data/database/app_database.dart';
import 'package:memo_app/data/repositories/note_repository.dart';

import '../helpers/test_database.dart';

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
  });
}
