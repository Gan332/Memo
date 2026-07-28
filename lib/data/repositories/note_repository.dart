import 'package:drift/drift.dart';

import '../database/app_database.dart';

class NoteRepository {
  final AppDatabase _db;

  NoteRepository(this._db);

  Future<List<NoteWithTags>> getNotes({
    String? searchQuery,
    bool? isArchived,
    bool? isPinned,
    String? noteType,
    int? tagId,
  }) async {
    var query = _db.select(_db.notes);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
        ..where((n) =>
            n.title.like('%$searchQuery%') | n.content.like('%$searchQuery%'));
    }

    if (isArchived != null) {
      query = query..where((n) => n.isArchived.equals(isArchived));
    }

    if (isPinned != null) {
      query = query..where((n) => n.isPinned.equals(isPinned));
    }

    if (noteType != null) {
      query = query..where((n) => n.noteType.equals(noteType));
    }

    query = query
      ..orderBy([
        (n) => OrderingTerm.desc(n.isPinned),
        (n) => OrderingTerm.desc(n.updatedAt)
      ]);

    final notes = await query.get();

    if (tagId != null) {
      final noteIdsWithTag = await (_db.select(_db.noteTags)
            ..where((nt) => nt.tagId.equals(tagId)))
          .get();
      final tagNoteIds = noteIdsWithTag.map((nt) => nt.noteId).toSet();
      return notes
          .where((n) => tagNoteIds.contains(n.id))
          .map((n) => NoteWithTags(note: n, tags: []))
          .toList();
    }

    return Future.wait(notes.map((n) async {
      final tags = await getTagsForNote(n.id);
      return NoteWithTags(note: n, tags: tags);
    }).toList());
  }

  Future<NoteWithTags?> getNote(int id) async {
    final note = await (_db.select(_db.notes)..where((n) => n.id.equals(id)))
        .getSingleOrNull();
    if (note == null) return null;
    final tags = await getTagsForNote(id);
    return NoteWithTags(note: note, tags: tags);
  }

  Future<int> insertNote(NotesCompanion note) {
    return _db.into(_db.notes).insert(note);
  }

  Future<bool> updateNote(NotesCompanion note) {
    return _db.update(_db.notes).replace(note);
  }

  Future<int> deleteNote(int id) {
    return (_db.delete(_db.notes)..where((n) => n.id.equals(id))).go();
  }

  Future<void> togglePin(int id, bool currentPinned) async {
    final note = await (_db.select(_db.notes)..where((n) => n.id.equals(id)))
        .getSingleOrNull();
    if (note == null) return;

    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        isPinned: Value(!currentPinned),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> toggleArchive(int id, bool currentArchived) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        isArchived: Value(!currentArchived),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<List<Tag>> getTagsForNote(int noteId) async {
    final query = _db.select(_db.noteTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.noteTags.tagId)),
    ])
      ..where(_db.noteTags.noteId.equals(noteId));

    final results = await query.get();
    return results.map((row) => row.readTable(_db.tags)).toList();
  }

  Future<int> getNoteCount({bool? isArchived}) async {
    var countQuery = _db.select(_db.notes);
    if (isArchived != null) {
      countQuery = countQuery..where((n) => n.isArchived.equals(isArchived));
    }
    return countQuery.get().then((list) => list.length);
  }
}

class NoteWithTags {
  final NoteRow note;
  final List<Tag> tags;

  const NoteWithTags({required this.note, required this.tags});
}
