import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'package:memo_app/data/database/app_database.dart';

LazyDatabase openTestDatabase() {
  return LazyDatabase(() async {
    final dbFolder = Directory.systemTemp.createTempSync('memo_test_');
    final file = File(p.join(dbFolder.path, 'test.db'));
    return NativeDatabase(file);
  });
}

AppDatabase createTestDatabase() {
  return AppDatabase.testing(openTestDatabase());
}
