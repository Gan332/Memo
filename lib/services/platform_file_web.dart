import 'dart:convert';
import 'dart:html' as html;

Future<String> saveBackupToFile(String content) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final filename = 'memo_backup_${DateTime.now().millisecondsSinceEpoch}.json';
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
  return filename;
}

Future<String> loadBackupFromFile(String filePath) async {
  throw UnsupportedError('File load not supported on web');
}
