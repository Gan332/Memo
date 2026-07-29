import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../data/database/app_database.dart';

class ExportService {
  /// Export a single note as Markdown with YAML frontmatter.
  String formatAsMarkdown(NoteRow note, List<String> tagNames) {
    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('title: "${_escapeYaml(note.title)}"');
    buffer.writeln('created: ${note.createdAt}');
    buffer.writeln('updated: ${note.updatedAt}');
    if (tagNames.isNotEmpty) {
      buffer.writeln('tags: [${tagNames.map((t) => '"${_escapeYaml(t)}"').join(', ')}]');
    }
    buffer.writeln('---');
    buffer.writeln();
    if (note.title.isNotEmpty) buffer.writeln('# ${note.title}');
    buffer.writeln();
    buffer.writeln(note.content);
    return buffer.toString();
  }

  /// Export a single note as plain text.
  String formatAsText(NoteRow note) {
    final buffer = StringBuffer();
    buffer.writeln(note.title);
    buffer.writeln('=' * note.title.length);
    buffer.writeln();
    buffer.writeln(note.content);
    return buffer.toString();
  }

  /// Export a checklist note as Markdown.
  String formatChecklistAsMarkdown(
      NoteRow note, List<ChecklistItem> items) {
    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('title: "${_escapeYaml(note.title)}"');
    buffer.writeln('type: checklist');
    buffer.writeln('created: ${note.createdAt}');
    buffer.writeln('---');
    buffer.writeln();
    if (note.title.isNotEmpty) buffer.writeln('# ${note.title}');
    buffer.writeln();
    for (final item in items) {
      final checkbox = item.isCompleted ? '[x]' : '[ ]';
      buffer.writeln('- $checkbox ${item.itemText}');
    }
    return buffer.toString();
  }

  Future<String?> pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择导出目录',
    );
    return result;
  }

  Future<File> exportToFile(String directory, String fileName, String content) async {
    final file = File('$directory/$fileName');
    await file.writeAsString(content, flush: true);
    return file;
  }

  String sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }

  String _escapeYaml(String value) {
    return value.replaceAll('"', '\\"');
  }
}
