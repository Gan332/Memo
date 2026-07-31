import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:memo_app/data/database/app_database.dart';

LazyDatabase openTestDatabase() {
  return LazyDatabase(() async {
    // In-memory database avoids filesystem and platform-channel issues in tests
    return NativeDatabase.memory();
  });
}

AppDatabase createTestDatabase() {
  return AppDatabase.testing(openTestDatabase());
}
