import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import '../data/models/backup.dart';

class BackupService {
  final AppDatabase _db;

  BackupService({AppDatabase? db}) : _db = db ?? AppDatabase();

  Future<String> exportBackup() async {
    final notes = await (_db.select(_db.notes)).get();
    final tags = await (_db.select(_db.tags)).get();
    final noteTags = await (_db.select(_db.noteTags)).get();
    final checklistItems = await (_db.select(_db.checklistItems)).get();

    final backup = BackupData(
      schemaVersion: _db.schemaVersion,
      exportedAt: DateTime.now(),
      notes: notes,
      tags: tags,
      noteTags: noteTags,
      checklistItems: checklistItems,
    );

    return backup.toJsonString();
  }

  Future<BackupMetadata> importBackup(String jsonString) async {
    final backup = BackupData.fromJsonString(jsonString);

    if (backup.schemaVersion > _db.schemaVersion) {
      throw Exception(
          '备份版本 (${backup.schemaVersion}) 高于当前版本 (${_db.schemaVersion})');
    }

    int addedCount = 0;
    int updatedCount = 0;
    int skippedCount = 0;
    int failedCount = 0;

    final noteIdMap = <int, int>{};
    final tagIdMap = <int, int>{};

    await _db.transaction(() async {
      for (final note in backup.notes) {
        try {
          final existing = await (_db.select(_db.notes)
                ..where((n) =>
                    n.title.equals(note.title) &
                    n.createdAt.equals(note.createdAt)))
              .get();

          if (existing.isNotEmpty) {
            await (_db.update(_db.notes)
                  ..where((n) => n.id.equals(existing.first.id)))
                .write(NotesCompanion(
              title: Value(note.title),
              content: Value(note.content),
              noteType: Value(note.noteType),
              color: Value(note.color),
              isPinned: Value(note.isPinned),
              isArchived: Value(note.isArchived),
              updatedAt: Value(note.updatedAt),
            ));
            noteIdMap[note.id!] = existing.first.id!;
            updatedCount++;
          } else {
            final newId = await _db.into(_db.notes).insert(NotesCompanion.insert(
                  title: Value(note.title),
                  content: Value(note.content),
                  noteType: Value(note.noteType),
                  color: Value(note.color),
                  isPinned: Value(note.isPinned),
                  isArchived: Value(note.isArchived),
                  createdAt: note.createdAt,
                  updatedAt: note.updatedAt,
                ));
            noteIdMap[note.id!] = newId;
            addedCount++;
          }
        } catch (e) {
          failedCount++;
        }
      }

      for (final tag in backup.tags) {
        try {
          final existing = await (_db.select(_db.tags)
                ..where((t) => t.name.equals(tag.name)))
              .get();

          if (existing.isNotEmpty) {
            tagIdMap[tag.id!] = existing.first.id!;
          } else {
            final newId = await _db.into(_db.tags).insert(TagsCompanion.insert(
                  name: tag.name,
                  color: Value(tag.color),
                  createdAt: tag.createdAt,
                ));
            tagIdMap[tag.id!] = newId;
          }
        } catch (e) {
          failedCount++;
        }
      }

      for (final noteTag in backup.noteTags) {
        try {
          final newNoteId = noteIdMap[noteTag.noteId];
          final newTagId = tagIdMap[noteTag.tagId];
          if (newNoteId != null && newTagId != null) {
            final existing = await (_db.select(_db.noteTags)
                  ..where((nt) =>
                      nt.noteId.equals(newNoteId) & nt.tagId.equals(newTagId)))
                .get();
            if (existing.isEmpty) {
              await _db.into(_db.noteTags).insert(
                    NoteTagsCompanion.insert(
                        noteId: newNoteId, tagId: newTagId),
                  );
            }
          }
        } catch (e) {
          failedCount++;
        }
      }

      for (final item in backup.checklistItems) {
        try {
          final newNoteId = noteIdMap[item.noteId];
          if (newNoteId != null) {
            await _db.into(_db.checklistItems).insert(
                  ChecklistItemsCompanion.insert(
                    noteId: newNoteId,
                    itemText: item.itemText,
                    isCompleted: Value(item.isCompleted),
                    sortOrder: Value(item.sortOrder),
                  ),
                );
          }
        } catch (e) {
          failedCount++;
        }
      }
    });

    return BackupMetadata(
      noteCount: backup.notes.length,
      tagCount: backup.tags.length,
      checklistItemCount: backup.checklistItems.length,
      addedCount: addedCount,
      updatedCount: updatedCount,
      skippedCount: skippedCount,
      failedCount: failedCount,
    );
  }
}
