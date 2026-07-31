class MarkdownFormatResult {
  const MarkdownFormatResult({
    required this.text,
    required this.cursorOffset,
  });

  final String text;
  final int cursorOffset;
}

class MarkdownFormat {
  static MarkdownFormatResult wrap({
    required String text,
    required int selectionStart,
    required int selectionEnd,
    required String prefix,
    required String suffix,
  }) {
    if (selectionStart == selectionEnd) {
      final newText = '$text$prefix$suffix';
      return MarkdownFormatResult(
        text: newText,
        cursorOffset: newText.length - suffix.length,
      );
    }

    final selected = text.substring(selectionStart, selectionEnd);
    final newText =
        '${text.substring(0, selectionStart)}$prefix$selected$suffix'
        '${text.substring(selectionEnd)}';
    return MarkdownFormatResult(
      text: newText,
      cursorOffset:
          selectionStart + prefix.length + selected.length + suffix.length,
    );
  }

  static MarkdownFormatResult insertLinePrefix({
    required String text,
    required int selectionOffset,
    required String prefix,
    required bool suppressIfAlreadyPrefixed,
  }) {
    final lineStart = selectionOffset == 0
        ? 0
        : text.lastIndexOf('\n', selectionOffset - 1) + 1;
    final linePrefix = text.substring(lineStart, selectionOffset);
    final shouldAdd = !(suppressIfAlreadyPrefixed && linePrefix.startsWith('#'));
    final newText =
        '${text.substring(0, lineStart)}${shouldAdd ? prefix : ''}'
        '${text.substring(lineStart)}';
    return MarkdownFormatResult(
      text: newText,
      cursorOffset: selectionOffset + (shouldAdd ? prefix.length : 0),
    );
  }
}
