import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/domain/entities/note_entity.dart';

void main() {
  group('NoteEntity', () {
    test('should create note with default values', () {
      final now = DateTime.now();
      final note = NoteEntity(
        title: 'Test',
        content: 'Content',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.title, 'Test');
      expect(note.content, 'Content');
      expect(note.noteType, NoteType.text);
      expect(note.isPinned, false);
      expect(note.isArchived, false);
      expect(note.color, 0xFFFEF7E0);
    });

    test('copyWith should preserve unchanged fields', () {
      final now = DateTime.now();
      final note = NoteEntity(
        id: 1,
        title: 'Original',
        content: 'Content',
        noteType: NoteType.text,
        color: 0xFFE8F5E9,
        isPinned: true,
        isArchived: false,
        createdAt: now,
        updatedAt: now,
      );

      final updated = note.copyWith(title: 'Updated');

      expect(updated.id, 1);
      expect(updated.title, 'Updated');
      expect(updated.content, 'Content');
      expect(updated.noteType, NoteType.text);
      expect(updated.color, 0xFFE8F5E9);
      expect(updated.isPinned, true);
      expect(updated.isArchived, false);
      expect(updated.createdAt, now);
    });

    test('preview truncates long content', () {
      final now = DateTime.now();
      final longContent = 'A' * 100;
      final note = NoteEntity(
        title: 'Test',
        content: longContent,
        createdAt: now,
        updatedAt: now,
      );

      expect(note.preview.length, lessThanOrEqualTo(83));
      expect(note.preview, endsWith('...'));
    });

    test('preview keeps short content unchanged', () {
      final now = DateTime.now();
      final note = NoteEntity(
        title: 'Test',
        content: 'Short',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.preview, 'Short');
    });

    test('backgroundColor returns correct Color', () {
      final now = DateTime.now();
      final note = NoteEntity(
        title: 'Test',
        content: '',
        color: 0xFFE8F5E9,
        createdAt: now,
        updatedAt: now,
      );

      expect(note.backgroundColor.value, 0xFFE8F5E9);
    });
  });
}
