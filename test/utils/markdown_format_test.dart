import 'package:flutter_test/flutter_test.dart';

import 'package:memo_app/utils/markdown_format.dart';

void main() {
  group('MarkdownFormat', () {
    test('wrap inserts markers around selection', () {
      final result = MarkdownFormat.wrap(
        text: 'hello',
        selectionStart: 0,
        selectionEnd: 5,
        prefix: '**',
        suffix: '**',
      );

      expect(result.text, '**hello**');
      expect(result.cursorOffset, 9);
    });

    test('wrap places cursor between markers for empty selection', () {
      final result = MarkdownFormat.wrap(
        text: 'hello',
        selectionStart: 5,
        selectionEnd: 5,
        prefix: '**',
        suffix: '**',
      );

      expect(result.text, 'hello****');
      expect(result.cursorOffset, 7);
    });

    test('insertLinePrefix adds heading and list prefixes', () {
      final heading = MarkdownFormat.insertLinePrefix(
        text: 'hello',
        selectionOffset: 5,
        prefix: '# ',
        suppressIfAlreadyPrefixed: true,
      );
      final bullet = MarkdownFormat.insertLinePrefix(
        text: 'hello',
        selectionOffset: 5,
        prefix: '- ',
        suppressIfAlreadyPrefixed: false,
      );

      expect(heading.text, '# hello');
      expect(heading.cursorOffset, 7);
      expect(bullet.text, '- hello');
      expect(bullet.cursorOffset, 7);
    });
  });
}
