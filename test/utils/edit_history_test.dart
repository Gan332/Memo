import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/utils/edit_history.dart';

void main() {
  test('push stores history and ignores identical state', () {
    final history = EditHistory(initial: 'a');

    history.push('a');
    expect(history.canUndo, false);
    expect(history.currentState, 'a');

    history.push('b');
    history.push('c');
    expect(history.canUndo, true);
    expect(history.currentState, 'c');
  });

  test('undo and redo restore previous states', () {
    final history = EditHistory(initial: 'a');
    history.push('b');
    history.push('c');

    expect(history.undo(), 'b');
    expect(history.undo(), 'a');
    expect(history.canUndo, false);

    expect(history.redo(), 'b');
    expect(history.redo(), 'c');
    expect(history.canRedo, false);
  });

  test('undo returns null when history is empty', () {
    final history = EditHistory(initial: 'a');

    expect(history.undo(), isNull);
    expect(history.redo(), isNull);
  });

  test('push clears the redo stack', () {
    final history = EditHistory(initial: 'a');
    history.push('b');
    history.undo();
    expect(history.canRedo, true);

    history.push('c');
    expect(history.canRedo, false);
  });

  test('clear resets both stacks but keeps current state', () {
    final history = EditHistory(initial: 'a');
    history.push('b');
    history.clear();

    expect(history.currentState, 'b');
    expect(history.canUndo, false);
    expect(history.canRedo, false);
  });
}
