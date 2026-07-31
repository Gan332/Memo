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
    bool? hasReminder,
    bool includeTrashed = false,
  }) async {
    var query = _db.select(_db.notes);

    if (!includeTrashed) {
      query = query..where((n) => n.isDeleted.equals(false));
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      try {
        final ftsIds = await _searchFtsIds(searchQuery);
        if (ftsIds.isEmpty) return [];
        query = query..where((n) => n.id.isIn(ftsIds));
      } catch (_) {
        // FTS5 not available, fallback to LIKE
        query = query..where((n) =>
            n.title.like('%$searchQuery%') | n.content.like('%$searchQuery%'));
      }
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

    if (hasReminder != null) {
      if (hasReminder) {
        query = query..where((n) => n.reminderTimestamp.isNotNull());
      } else {
        query = query..where((n) => n.reminderTimestamp.isNull());
      }
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

  Future<void> deleteNote(int id) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now().toIso8601String()),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> restoreNote(int id) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        isDeleted: const Value(false),
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<Set<int>> _searchFtsIds(String query) async {
    String sanitize(String s) {
      return s.replaceAllMapped(
        RegExp(r'[\^\*\"\-\+\~\[\]\(\)]'),
        (m) => '${m.group(0)}',
      );
    }

    final ftsQuery = '"${sanitize(query)}"*';
    final idRows = await _db.customSelect(
      'SELECT rowid FROM notes_fts WHERE notes_fts MATCH ? ORDER BY rank',
      variables: [Variable.withString(ftsQuery)],
      readsFrom: {_db.notes},
    ).get();

    // Deduplicate to preserve order
    final ordered = <int>[];
    for (final r in idRows) {
      final id = r.read<int>('rowid');
      if (!ordered.contains(id)) ordered.add(id);
    }
    return ordered.toSet();
  }

  Future<void> permanentlyDeleteNote(int id) async {
    // Remove tag associations first
    await (_db.delete(_db.noteTags)..where((nt) => nt.noteId.equals(id))).go();
    // Remove checklist items
    await (_db.delete(_db.checklistItems)
          ..where((ci) => ci.noteId.equals(id)))
        .go();
    // Remove attachments
    await (_db.delete(_db.attachments)
          ..where((a) => a.noteId.equals(id)))
        .go();
    await (_db.delete(_db.notes)..where((n) => n.id.equals(id))).go();
  }

  Future<void> emptyTrash() async {
    final trashedNotes =
        await (_db.select(_db.notes)..where((n) => n.isDeleted.equals(true)))
            .get();
    for (final note in trashedNotes) {
      await permanentlyDeleteNote(note.id);
    }
  }

  Future<List<NoteWithTags>> getTrashedNotes() async {
    var query = _db.select(_db.notes)
      ..where((n) => n.isDeleted.equals(true))
      ..orderBy([(n) => OrderingTerm.desc(n.deletedAt)]);

    final notes = await query.get();
    return Future.wait(notes.map((n) async {
      final tags = await getTagsForNote(n.id);
      return NoteWithTags(note: n, tags: tags);
    }).toList());
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

  Future<int> getNoteCount({bool? isArchived, bool includeTrashed = false}) async {
    var countQuery = _db.select(_db.notes);
    if (!includeTrashed) {
      countQuery = countQuery..where((n) => n.isDeleted.equals(false));
    }
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
