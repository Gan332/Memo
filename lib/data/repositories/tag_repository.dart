import 'package:drift/drift.dart';

import '../database/app_database.dart';

class TagRepository {
  final AppDatabase _db;

  TagRepository(this._db);

  Future<List<Tag>> getAllTags() {
    return (_db.select(_db.tags)..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<int> insertTag(TagsCompanion tag) {
    return _db.into(_db.tags).insert(tag);
  }

  Future<bool> updateTag(TagsCompanion tag) {
    return _db.update(_db.tags).replace(tag);
  }

  Future<int> deleteTag(int id) async {
    // Remove associations first, then delete tag
    await (_db.delete(_db.noteTags)..where((nt) => nt.tagId.equals(id))).go();
    return (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
  }

  Future<int> getTagCount() {
    return _db.select(_db.tags).get().then((list) => list.length);
  }
}
