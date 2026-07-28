import 'package:flutter/foundation.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/tag_repository.dart';
import '../../domain/entities/tag_entity.dart';

class TagProvider extends ChangeNotifier {
  final AppDatabase _db;
  late final TagRepository _tagRepository;

  List<TagEntity> _tags = [];
  bool _isLoading = false;
  String _error = '';

  TagProvider({AppDatabase? db})
      : _db = db ?? AppDatabase(),
        _tagRepository = TagRepository(db ?? AppDatabase());

  List<TagEntity> get tags => _tags;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadTags() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final tagRows = await _tagRepository.getAllTags();
      _tags = tagRows
          .map((t) => TagEntity(
                id: t.id,
                name: t.name,
                color: t.color,
                createdAt: DateTime.parse(t.createdAt),
              ))
          .toList();
    } catch (e) {
      _error = '加载标签失败: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<int> addTag(String name, {int color = 0xFF42A5F5}) async {
    final id = await _tagRepository.insertTag(TagsCompanion.insert(
      name: name,
      color: Value(color),
      createdAt: DateTime.now().toIso8601String(),
    ));
    await loadTags();
    return id;
  }

  Future<void> updateTag(TagEntity tag) async {
    if (tag.id == null) return;
    await _tagRepository.updateTag(TagsCompanion(
      id: Value(tag.id!),
      name: Value(tag.name),
      color: Value(tag.color),
      createdAt: Value(tag.createdAt.toIso8601String()),
    ));
    await loadTags();
  }

  Future<void> deleteTag(int id) async {
    await _tagRepository.deleteTag(id);
    await loadTags();
  }

  Future<void> addTagToNote(int noteId, int tagId) async {
    await _db.into(_db.noteTags).insert(
          NoteTagsCompanion.insert(noteId: noteId, tagId: tagId),
        );
  }

  Future<void> removeTagFromNote(int noteId, int tagId) async {
    await (_db.delete(_db.noteTags)
          ..where((nt) => nt.noteId.equals(noteId) & nt.tagId.equals(tagId)))
        .go();
  }

  Future<List<int>> getTagIdsForNote(int noteId) async {
    final result = await (_db.select(_db.noteTags)
          ..where((nt) => nt.noteId.equals(noteId)))
        .get();
    return result.map((nt) => nt.tagId).toList();
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }
}
