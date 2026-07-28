import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/domain/entities/tag_entity.dart';

void main() {
  group('TagEntity', () {
    test('should create with default values', () {
      final tag = TagEntity(
        name: 'important',
        createdAt: DateTime(2025, 1, 15),
      );

      expect(tag.name, 'important');
      expect(tag.color, 0xFF42A5F5);
      expect(tag.id, null);
    });

    test('copyWith should preserve unchanged fields', () {
      final tag = TagEntity(
        id: 1,
        name: 'original',
        color: 0xFF42A5F5,
        createdAt: DateTime(2025, 1, 15),
      );

      final updated = tag.copyWith(name: 'renamed', color: 0xFF66BB6A);

      expect(updated.id, 1);
      expect(updated.name, 'renamed');
      expect(updated.color, 0xFF66BB6A);
      expect(updated.createdAt, DateTime(2025, 1, 15));
    });

    test('backgroundColor returns correct Color', () {
      final tag = TagEntity(
        name: 'test',
        color: 0xFF66BB6A,
        createdAt: DateTime.now(),
      );

      expect(tag.backgroundColor.value, 0xFF66BB6A);
    });
  });
}
