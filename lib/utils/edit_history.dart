class EditHistory {
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  String _currentState;

  EditHistory({String initial = ''}) : _currentState = initial;

  String get currentState => _currentState;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void push(String newState) {
    if (newState == _currentState) return;
    _undoStack.add(_currentState);
    _redoStack.clear();
    _currentState = newState;
  }

  String? undo() {
    if (!canUndo) return null;
    _redoStack.add(_currentState);
    _currentState = _undoStack.removeLast();
    return _currentState;
  }

  String? redo() {
    if (!canRedo) return null;
    _undoStack.add(_currentState);
    _currentState = _redoStack.removeLast();
    return _currentState;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
