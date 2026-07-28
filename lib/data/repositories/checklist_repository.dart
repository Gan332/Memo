import 'package:drift/drift.dart';

import '../database/app_database.dart';

class ChecklistRepository {
  final AppDatabase _db;

  ChecklistRepository(this._db);

  Future<List<ChecklistItem>> getItemsForNote(int noteId) {
    return (_db.select(_db.checklistItems)
          ..where((ci) => ci.noteId.equals(noteId))
          ..orderBy([(ci) => OrderingTerm.asc(ci.sortOrder)]))
        .get();
  }

  Future<int> insertItem(ChecklistItemsCompanion item) {
    return _db.into(_db.checklistItems).insert(item);
  }

  Future<bool> updateItem(ChecklistItemsCompanion item) {
    return _db.update(_db.checklistItems).replace(item);
  }

  Future<int> deleteItem(int id) {
    return (_db.delete(_db.checklistItems)..where((ci) => ci.id.equals(id)))
        .go();
  }

  Future<int> deleteItemsForNote(int noteId) {
    return (_db.delete(_db.checklistItems)
          ..where((ci) => ci.noteId.equals(noteId)))
        .go();
  }

  Future<void> reorderItems(List<ChecklistItem> items) async {
    for (var i = 0; i < items.length; i++) {
      await (_db.update(_db.checklistItems)
            ..where((ci) => ci.id.equals(items[i].id)))
          .write(ChecklistItemsCompanion(
        sortOrder: Value(i),
      ));
    }
  }
}
