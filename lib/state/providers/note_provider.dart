import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/note_repository.dart';
import '../../domain/entities/note_entity.dart';

enum SortBy { updatedAt, createdAt, title }

class NoteProvider extends ChangeNotifier {
  final AppDatabase _db;
  late final NoteRepository _noteRepository;

  List<NoteRow> _notes = [];
  List<NoteRow> _archivedNotes = [];
  List<NoteRow> _trashedNotes = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  bool? _filterArchived;
  bool? _filterPinned;
  String? _filterNoteType;
  int? _filterTagId;
  bool? _filterHasReminder;
  SortBy _sortBy = SortBy.updatedAt;
  bool _sortAscending = false;
  Timer? _debounceTimer;

  final Set<int> _selectedNoteIds = {};
  bool _isMultiSelectMode = false;

  NoteProvider({AppDatabase? db})
      : _db = db ?? AppDatabase(),
        _noteRepository = NoteRepository(db ?? AppDatabase()) {
    _loadSortPreference();
  }

  List<NoteRow> get notes => _notes;
  List<NoteRow> get archivedNotes => _archivedNotes;
  List<NoteRow> get trashedNotes => _trashedNotes;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  bool? get filterArchived => _filterArchived;
  bool? get filterPinned => _filterPinned;
  String? get filterNoteType => _filterNoteType;
  int? get filterTagId => _filterTagId;
  bool? get filterHasReminder => _filterHasReminder;
  SortBy get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  bool get isMultiSelectMode => _isMultiSelectMode;
  Set<int> get selectedNoteIds => Set.unmodifiable(_selectedNoteIds);
  int get selectedCount => _selectedNoteIds.length;

  bool get isFiltering =>
      _searchQuery.isNotEmpty ||
      _filterArchived != null ||
      _filterPinned != null ||
      _filterNoteType != null ||
      _filterTagId != null ||
      _filterHasReminder != null;

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final sortIndex = prefs.getInt('sortBy') ?? 0;
    _sortBy = SortBy.values[sortIndex];
    _sortAscending = prefs.getBool('sortAscending') ?? false;
    notifyListeners();
  }

  Future<void> setSortBy(SortBy sortBy, {bool? ascending}) async {
    _sortBy = sortBy;
    _sortAscending = ascending ?? (_sortBy == SortBy.title);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sortBy', _sortBy.index);
    await prefs.setBool('sortAscending', _sortAscending);
    _sortNotes();
    notifyListeners();
  }

  void _sortNotes() {
    _notes.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case SortBy.updatedAt:
          comparison = DateTime.parse(a.updatedAt)
              .compareTo(DateTime.parse(b.updatedAt));
        case SortBy.createdAt:
          comparison = DateTime.parse(a.createdAt)
              .compareTo(DateTime.parse(b.createdAt));
        case SortBy.title:
          comparison = a.title.compareTo(b.title);
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _notes = (await _noteRepository.getNotes(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        isArchived: _filterArchived,
        isPinned: _filterPinned,
        noteType: _filterNoteType,
        tagId: _filterTagId,
        hasReminder: _filterHasReminder,
      ))
          .map((nwt) => nwt.note)
          .toList();
      _archivedNotes = (await _noteRepository.getNotes(isArchived: true))
          .map((nwt) => nwt.note)
          .toList();
      _sortNotes();
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
    bool? hasReminder,
  }) {
    _filterArchived = archived;
    _filterPinned = pinned;
    _filterNoteType = noteType;
    _filterTagId = tagId;
    _filterHasReminder = hasReminder;
    loadNotes();
  }

  void clearFilters() {
    _filterArchived = null;
    _filterPinned = null;
    _filterNoteType = null;
    _filterTagId = null;
    _filterHasReminder = null;
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
      reminderTimestamp: Value(note.reminderTimestamp),
      reminderFired: Value(note.reminderFired),
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
      reminderTimestamp: Value(note.reminderTimestamp),
      reminderFired: Value(note.reminderFired),
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

  Future<void> restoreNote(int id) async {
    await _noteRepository.restoreNote(id);
    await loadNotes();
    await loadTrashedNotes();
  }

  Future<void> permanentlyDeleteNote(int id) async {
    await _noteRepository.permanentlyDeleteNote(id);
    await loadTrashedNotes();
  }

  Future<void> emptyTrash() async {
    await _noteRepository.emptyTrash();
    await loadTrashedNotes();
  }

  Future<void> loadTrashedNotes() async {
    try {
      _trashedNotes = (await _noteRepository.getTrashedNotes())
          .map((nwt) => nwt.note)
          .toList();
      notifyListeners();
    } catch (e) {
      _error = '加载回收站失败: $e';
      notifyListeners();
    }
  }

  Future<void> setReminder(int noteId, int timestamp) async {
    await _noteRepository.updateNote(NotesCompanion(
      id: Value(noteId),
      reminderTimestamp: Value(timestamp),
      reminderFired: const Value(false),
    ));
    await loadNotes();
  }

  Future<void> clearReminder(int noteId) async {
    await _noteRepository.updateNote(NotesCompanion(
      id: Value(noteId),
      reminderTimestamp: const Value(null),
      reminderFired: const Value(null),
    ));
    await loadNotes();
  }

  Future<void> checkPendingReminders() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    try {
      final allNotes = await _noteRepository.getNotes();
      for (final nwt in allNotes) {
        final note = nwt.note;
        if (note.reminderTimestamp != null &&
            note.reminderFired != true &&
            note.reminderTimestamp! <= now) {
          await _noteRepository.updateNote(NotesCompanion(
            id: Value(note.id),
            reminderFired: const Value(true),
          ));
        }
      }
    } catch (_) {
      // Silently handle reminder check failures
    }
  }

  Future<void> restoreDeletedNote(NoteRow note) async {
    await _noteRepository.insertNote(NotesCompanion.insert(
      title: Value(note.title),
      content: Value(note.content),
      noteType: Value(note.noteType),
      color: Value(note.color),
      isPinned: Value(note.isPinned),
      isArchived: Value(note.isArchived),
      reminderTimestamp: Value(note.reminderTimestamp),
      reminderFired: Value(note.reminderFired),
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    ));
    await loadNotes();
  }

  Future<int> getNoteCount({bool? isArchived}) async {
    return _noteRepository.getNoteCount(isArchived: isArchived);
  }

  // Multi-select operations
  void enterMultiSelectMode() {
    _isMultiSelectMode = true;
    _selectedNoteIds.clear();
    notifyListeners();
  }

  void exitMultiSelectMode() {
    _isMultiSelectMode = false;
    _selectedNoteIds.clear();
    notifyListeners();
  }

  void toggleNoteSelection(int noteId) {
    if (_selectedNoteIds.contains(noteId)) {
      _selectedNoteIds.remove(noteId);
    } else {
      _selectedNoteIds.add(noteId);
    }
    if (_selectedNoteIds.isEmpty) {
      _isMultiSelectMode = false;
    }
    notifyListeners();
  }

  void selectAllNotes() {
    _selectedNoteIds.addAll(_notes.map((n) => n.id));
    notifyListeners();
  }

  void deselectAllNotes() {
    _selectedNoteIds.clear();
    notifyListeners();
  }

  Future<void> deleteSelectedNotes() async {
    for (final id in _selectedNoteIds) {
      await _noteRepository.deleteNote(id);
    }
    _isMultiSelectMode = false;
    _selectedNoteIds.clear();
    await loadNotes();
  }

  Future<void> deleteSelectedNotesPermanently() async {
    for (final id in _selectedNoteIds) {
      await _noteRepository.permanentlyDeleteNote(id);
    }
    _isMultiSelectMode = false;
    _selectedNoteIds.clear();
    await loadTrashedNotes();
  }

  Future<void> archiveSelectedNotes() async {
    for (final id in _selectedNoteIds) {
      final note = _notes.firstWhere((n) => n.id == id);
      await _noteRepository.toggleArchive(id, note.isArchived);
    }
    _isMultiSelectMode = false;
    _selectedNoteIds.clear();
    await loadNotes();
  }

  Future<void> pinSelectedNotes() async {
    for (final id in _selectedNoteIds) {
      final note = _notes.firstWhere((n) => n.id == id);
      await _noteRepository.togglePin(id, note.isPinned);
    }
    _isMultiSelectMode = false;
    _selectedNoteIds.clear();
    await loadNotes();
  }

  Future<void> tagSelectedNotes(int tagId) async {
    for (final id in _selectedNoteIds) {
      await _db.into(_db.noteTags).insert(
            NoteTagsCompanion.insert(noteId: id, tagId: tagId),
          );
    }
    _isMultiSelectMode = false;
    _selectedNoteIds.clear();
    await loadNotes();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
