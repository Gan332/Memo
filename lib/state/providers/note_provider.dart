import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' hide Column;

import '../data/database/app_database.dart';
import '../data/repositories/note_repository.dart';
import '../domain/entities/note_entity.dart';

class NoteProvider extends ChangeNotifier {
  final AppDatabase _db;
  late final NoteRepository _noteRepository;

  List<NoteRow> _notes = [];
  List<NoteRow> _archivedNotes = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  bool? _filterArchived;
  bool? _filterPinned;
  String? _filterNoteType;
  int? _filterTagId;
  Timer? _debounceTimer;

  NoteProvider({AppDatabase? db})
      : _db = db ?? AppDatabase(),
        _noteRepository = NoteRepository(db ?? AppDatabase());

  List<NoteRow> get notes => _notes;
  List<NoteRow> get archivedNotes => _archivedNotes;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  bool? get filterArchived => _filterArchived;
  bool? get filterPinned => _filterPinned;
  String? get filterNoteType => _filterNoteType;
  int? get filterTagId => _filterTagId;

  bool get isFiltering =>
      _searchQuery.isNotEmpty ||
      _filterArchived != null ||
      _filterPinned != null ||
      _filterNoteType != null ||
      _filterTagId != null;

  Future<void> loadNotes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _notes = await _noteRepository.getNotes(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        isArchived: _filterArchived,
        isPinned: _filterPinned,
        noteType: _filterNoteType,
        tagId: _filterTagId,
      );
      _archivedNotes = await _noteRepository.getNotes(isArchived: true);
    } catch (e) {
      _error = '加载笔记失败: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      loadNotes();
    });
    notifyListeners();
  }

  void setFilter({
    bool? archived,
    bool? pinned,
    String? noteType,
    int? tagId,
  }) {
    _filterArchived = archived;
    _filterPinned = pinned;
    _filterNoteType = noteType;
    _filterTagId = tagId;
    loadNotes();
  }

  void clearFilters() {
    _filterArchived = null;
    _filterPinned = null;
    _filterNoteType = null;
    _filterTagId = null;
    _searchQuery = '';
    loadNotes();
  }

  Future<NoteWithTags?> getNote(int id) async {
    return await _noteRepository.getNote(id);
  }

  Future<int> addNote(NoteEntity note) async {
    final id = await _noteRepository.insertNote(NotesCompanion(
      title: Value(note.title),
      content: Value(note.content),
      noteType: Value(note.noteType.name),
      color: Value(note.color),
      isPinned: Value(note.isPinned),
      isArchived: Value(note.isArchived),
      createdAt: Value(note.createdAt.toIso8601String()),
      updatedAt: Value(note.updatedAt.toIso8601String()),
    ));
    await loadNotes();
    return id;
  }

  Future<void> updateNote(NoteEntity note) async {
    if (note.id == null) return;
    await _noteRepository.updateNote(NotesCompanion(
      id: Value(note.id!),
      title: Value(note.title),
      content: Value(note.content),
      noteType: Value(note.noteType.name),
      color: Value(note.color),
      isPinned: Value(note.isPinned),
      isArchived: Value(note.isArchived),
      createdAt: Value(note.createdAt.toIso8601String()),
      updatedAt: Value(note.updatedAt.toIso8601String()),
    ));
    await loadNotes();
  }

  Future<void> togglePin(int id, bool currentPinned) async {
    await _noteRepository.togglePin(id, currentPinned);
    await loadNotes();
  }

  Future<void> toggleArchive(int id, bool currentArchived) async {
    await _noteRepository.toggleArchive(id, currentArchived);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await _noteRepository.deleteNote(id);
    await loadNotes();
  }

  Future<void> restoreDeletedNote(NoteRow note) async {
    await _noteRepository.insertNote(NotesCompanion.insert(
      title: note.title,
      content: note.content,
      noteType: note.noteType,
      color: note.color,
      isPinned: Value(note.isPinned),
      isArchived: Value(note.isArchived),
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    ));
    await loadNotes();
  }

  Future<int> getNoteCount({bool? isArchived}) async {
    return _noteRepository.getNoteCount(isArchived: isArchived);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _db.close();
    super.dispose();
  }
}
