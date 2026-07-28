import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> saveBackupToFile(String content) async {
  final directory = await getApplicationDocumentsDirectory();
  final filename = 'memo_backup_${DateTime.now().millisecondsSinceEpoch}.json';
  final file = File('${directory.path}/$filename');
  await file.writeAsString(content);
  return file.path;
}

Future<String> loadBackupFromFile(String filePath) async {
  final file = File(filePath);
  return await file.readAsString();
}
