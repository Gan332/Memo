import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/state/providers/note_provider.dart';
import 'package:memo_app/data/database/app_database.dart';
import 'package:memo_app/domain/entities/note_entity.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late NoteProvider provider;

  setUp(() async {
    db = createTestDatabase();
    provider = NoteProvider(db: db);
    await provider.loadNotes();
  });

  tearDown(() async {
    provider.dispose();
    await db.close();
  });

  group('NoteProvider', () {
    test('initial state is empty notes list', () {
      expect(provider.notes, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, '');
    });

    test('addNote adds note to list', () async {
      final now = DateTime.now();
      final note = NoteEntity(
        title: 'Test',
        content: 'Content',
        createdAt: now,
        updatedAt: now,
      );

      await provider.addNote(note);
      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Test');
    });

    test('loadNotes loads all notes', () async {
      final now = DateTime.now();
      final note1 = NoteEntity(
        title: 'Note 1',
        content: 'Content 1',
        createdAt: now,
        updatedAt: now,
      );
      final note2 = NoteEntity(
        title: 'Note 2',
        content: 'Content 2',
        createdAt: now,
        updatedAt: now,
      );

      await provider.addNote(note1);
      await provider.addNote(note2);

      expect(provider.notes.length, 2);
    });

    test('setFilter filters by archived', () async {
      final now = DateTime.now();
      final active = NoteEntity(
        title: 'Active',
        content: '',
        createdAt: now,
        updatedAt: now,
      );
      final archived = NoteEntity(
        title: 'Archived',
        content: '',
        isArchived: true,
        createdAt: now,
        updatedAt: now,
      );

      await provider.addNote(active);
      await provider.addNote(archived);

      provider.setFilter(archived: false);
      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Active');
    });

    test('setFilter filters by hasReminder', () async {
      final now = DateTime.now();
      final withReminder = NoteEntity(
        title: 'With Reminder',
        content: '',
        reminderTimestamp: 1800000000,
        reminderFired: false,
        createdAt: now,
        updatedAt: now,
      );
      final withoutReminder = NoteEntity(
        title: 'No Reminder',
        content: '',
        createdAt: now,
        updatedAt: now,
      );

      await provider.addNote(withReminder);
      await provider.addNote(withoutReminder);

      provider.setFilter(hasReminder: true);
      expect(provider.isFiltering, true);
      await provider.loadNotes();

      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'With Reminder');
      expect(provider.notes.first.reminderTimestamp, 1800000000);
    });

    test('clearFilters resets all filters', () async {
      final now = DateTime.now();
      final note = NoteEntity(
        title: 'Test',
        content: '',
        createdAt: now,
        updatedAt: now,
      );

      await provider.addNote(note);

      provider.setFilter(archived: false);
      expect(provider.filterArchived, false);

      provider.clearFilters();
      expect(provider.filterArchived, isNull);
      expect(provider.filterPinned, isNull);
      expect(provider.filterNoteType, isNull);
      expect(provider.filterTagId, isNull);
      expect(provider.filterHasReminder, isNull);
      expect(provider.searchQuery, '');
    });

    test('deleteNote removes note', () async {
      final now = DateTime.now();
      final note = NoteEntity(
        title: 'To Delete',
        content: '',
        createdAt: now,
        updatedAt: now,
      );

      final id = await provider.addNote(note);
      expect(provider.notes.length, 1);

      await provider.deleteNote(id);
      expect(provider.notes.length, 0);
    });

    test('togglePin changes pin status', () async {
      final now = DateTime.now();
      final note = NoteEntity(
        title: 'Pinned',
        content: '',
        createdAt: now,
        updatedAt: now,
      );

      final id = await provider.addNote(note);
      expect(provider.notes.first.isPinned, false);

      await provider.togglePin(id, false);
      expect(provider.notes.first.isPinned, true);
    });

    test('searchQuery filters notes', () async {
      final now = DateTime.now();
      final flutter = NoteEntity(
        title: 'Flutter',
        content: '',
        createdAt: now,
        updatedAt: now,
      );
      final dart = NoteEntity(
        title: 'Dart',
        content: '',
        createdAt: now,
        updatedAt: now,
      );

      await provider.addNote(flutter);
      await provider.addNote(dart);

      provider.setSearchQuery('Flutter');
      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 400));

      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Flutter');
    });

    test('isFiltering returns true when filters are set', () async {
      expect(provider.isFiltering, false);

      provider.setFilter(archived: true);
      expect(provider.isFiltering, true);
    });
  });
}
