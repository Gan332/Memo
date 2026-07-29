import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../domain/entities/checklist_entity.dart';

class ChecklistProvider extends ChangeNotifier {
  late final ChecklistRepository _checklistRepository;

  List<ChecklistEntity> _items = [];
  bool _isLoading = false;
  String _error = '';

  ChecklistProvider({AppDatabase? db})
      : _checklistRepository = ChecklistRepository(db ?? AppDatabase());

  List<ChecklistEntity> get items => _items;
  bool get isLoading => _isLoading;
  String get error => _error;

  int get completedCount => _items.where((i) => i.isCompleted).length;
  int get totalCount => _items.length;
  double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;

  Future<void> loadItems(int noteId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final items = await _checklistRepository.getItemsForNote(noteId);
      _items = items
          .map((i) => ChecklistEntity(
                id: i.id,
                noteId: i.noteId,
                text: i.itemText,
                isCompleted: i.isCompleted,
                sortOrder: i.sortOrder,
              ))
          .toList();
    } catch (e) {
      _error = '加载清单失败: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<int> addItem(int noteId, String text) async {
    final id = await _checklistRepository.insertItem(
      ChecklistItemsCompanion.insert(
        noteId: noteId,
        itemText: text,
        sortOrder: Value(_items.length),
      ),
    );
    await loadItems(noteId);
    return id;
  }

  Future<void> updateItem(ChecklistEntity item) async {
    if (item.id == null) return;
    await _checklistRepository.updateItem(ChecklistItemsCompanion(
      id: Value(item.id!),
      noteId: Value(item.noteId),
      itemText: Value(item.text),
      isCompleted: Value(item.isCompleted),
      sortOrder: Value(item.sortOrder),
    ));
    await loadItems(item.noteId);
  }

  Future<void> toggleItem(int id, bool currentCompleted, int noteId) async {
    final item = _items.firstWhere((i) => i.id == id);
    await updateItem(item.copyWith(isCompleted: !currentCompleted));
  }

  Future<void> deleteItem(int id, int noteId) async {
    await _checklistRepository.deleteItem(id);
    await loadItems(noteId);
  }

  Future<List<ChecklistItem>> getItems(int noteId) async {
    return _checklistRepository.getItemsForNote(noteId);
  }

  Future<void> deleteItemsForNote(int noteId) async {
    await _checklistRepository.deleteItemsForNote(noteId);
    _items = [];
    notifyListeners();
  }

  Future<void> reorder(int oldIndex, int newIndex, int noteId) async {
    if (oldIndex < newIndex) newIndex--;
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    notifyListeners();

    await _checklistRepository.reorderItems(
      _items.asMap().entries.map((e) {
        final item = e.value;
        return ChecklistEntity(
          id: item.id,
          noteId: item.noteId,
          text: item.text,
          isCompleted: item.isCompleted,
          sortOrder: e.key,
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
