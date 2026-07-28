import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/domain/entities/checklist_entity.dart';

void main() {
  group('ChecklistEntity', () {
    test('should create with default values', () {
      final item = ChecklistEntity(
        noteId: 1,
        text: 'Buy milk',
      );

      expect(item.noteId, 1);
      expect(item.text, 'Buy milk');
      expect(item.isCompleted, false);
      expect(item.sortOrder, 0);
    });

    test('copyWith should preserve unchanged fields', () {
      final item = ChecklistEntity(
        id: 1,
        noteId: 1,
        text: 'Original',
        isCompleted: false,
        sortOrder: 2,
      );

      final updated = item.copyWith(text: 'Updated', isCompleted: true);

      expect(updated.id, 1);
      expect(updated.noteId, 1);
      expect(updated.text, 'Updated');
      expect(updated.isCompleted, true);
      expect(updated.sortOrder, 2);
    });

    test('completionPercentage returns correct value', () {
      final incomplete = ChecklistEntity(
        noteId: 1,
        text: 'Task',
        isCompleted: false,
      );
      expect(incomplete.completionPercentage, 0);

      final complete = ChecklistEntity(
        noteId: 1,
        text: 'Task',
        isCompleted: true,
      );
      expect(complete.completionPercentage, 100);
    });
  });
}
