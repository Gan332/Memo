import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/data/database/app_database.dart';
import 'package:memo_app/data/repositories/note_repository.dart';
import 'package:memo_app/services/export_service.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late NoteRepository repository;
  late ExportService service;

  setUp(() {
    db = createTestDatabase();
    repository = NoteRepository(db);
    service = ExportService();
  });

  tearDown(() async {
    await db.close();
  });

  test('formatAsMarkdown writes frontmatter and title', () async {
    final noteId = await repository.insertNote(NotesCompanion.insert(
      title: Value('Hello'),
      content: Value('World'),
      createdAt: '2025-01-01T00:00:00',
      updatedAt: '2025-01-01T00:00:00',
    ));
    final note = (await repository.getNote(noteId))!;

    final markdown = service.formatAsMarkdown(note.note, []);

    expect(markdown, contains('title: "Hello"'));
    expect(markdown, contains('# Hello'));
    expect(markdown, contains('World'));
  });

  test('formatChecklistAsMarkdown renders checkbox items', () async {
    final noteId = await repository.insertNote(NotesCompanion.insert(
      title: Value('List'),
      content: Value(''),
      noteType: const Value('checklist'),
      createdAt: '2025-01-01T00:00:00',
      updatedAt: '2025-01-01T00:00:00',
    ));
    final note = (await repository.getNote(noteId))!.note;
    final items = [
      ChecklistItem(
        id: 1,
        noteId: noteId,
        itemText: 'done',
        isCompleted: true,
        sortOrder: 0,
      ),
      ChecklistItem(
        id: 2,
        noteId: noteId,
        itemText: 'todo',
        isCompleted: false,
        sortOrder: 1,
      ),
    ];

    final markdown = service.formatChecklistAsMarkdown(note, items);

    expect(markdown, contains('type: checklist'));
    expect(markdown, contains('- [x] done'));
    expect(markdown, contains('- [ ] todo'));
  });

  test('exportAllToDirectory writes one markdown file per note', () async {
    final directory = await Directory.systemTemp.createTemp('memo_export');
    addTearDown(() => directory.delete(recursive: true));

    await repository.insertNote(NotesCompanion.insert(
      title: Value('First'),
      content: Value('alpha'),
      createdAt: '2025-01-01T00:00:00',
      updatedAt: '2025-01-01T00:00:00',
    ));
    final checklistId = await repository.insertNote(NotesCompanion.insert(
      title: Value('Second'),
      content: Value(''),
      noteType: const Value('checklist'),
      createdAt: '2025-01-02T00:00:00',
      updatedAt: '2025-01-02T00:00:00',
    ));
    await db.into(db.checklistItems).insert(
          ChecklistItemsCompanion.insert(
            noteId: checklistId,
            itemText: 'nested',
            isCompleted: const Value(false),
            sortOrder: const Value(0),
          ),
        );

    final notes = await repository.getNotes();
    final count = await service.exportAllToDirectory(
      directory.path,
      notes,
      loadChecklistItems: (noteId) => repository.getChecklistItems(noteId),
    );

    expect(count, 2);
    final files = directory.listSync().whereType<File>().toList();
    expect(files.length, 2);

    final checklistContent = files
        .firstWhere((file) => file.path.contains('Second'))
        .readAsStringSync();
    expect(checklistContent, contains('- [ ] nested'));
  });

  test('sanitizeFileName removes illegal characters', () {
    expect(service.sanitizeFileName('a<b>:"/\\|?*c'), 'a_b_________c');
  });
}
