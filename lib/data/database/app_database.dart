import 'package:drift/drift.dart';

import 'connection.dart';

part 'app_database.g.dart';

@DataClassName('NoteRow')
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get noteType => text().withDefault(const Constant('text'))();
  IntColumn get color => integer().withDefault(const Constant(0xFFFEF7E0))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn? get deletedAt => text().nullable()();
  IntColumn? get reminderTimestamp => integer().nullable()();
  BoolColumn? get reminderFired => boolean().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  List<Set<Column>> get uniqueKeys => [];
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer().withDefault(const Constant(0xFF42A5F5))();
  TextColumn get createdAt => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name}
      ];
}

class NoteTags extends Table {
  IntColumn get noteId => integer().references(Notes, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

class ChecklistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get noteId => integer().references(Notes, #id)();
  TextColumn get itemText => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class NoteColorValues extends Table {
  IntColumn get value => integer()();
  TextColumn get label => text()();

  @override
  Set<Column> get primaryKey => {value};
}

class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get noteId => integer().references(Notes, #id)();
  TextColumn get filePath => text()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text()();

  @override
  List<Set<Column>> get uniqueKeys => [];
}

@DriftDatabase(tables: [
  Notes,
  Tags,
  NoteTags,
  ChecklistItems,
  NoteColorValues,
  Attachments,
])
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;

  AppDatabase._internal() : super(openConnection());

  AppDatabase.testing(super.e);

  factory AppDatabase() => _instance ??= AppDatabase._internal();

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedNoteColors();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(notes, notes.isDeleted);
            await m.addColumn(notes, notes.deletedAt);
          }
          if (from < 3) {
            await customStatement('''
              CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(
                title, content, content=notes, content_rowid=id
              );
            ''');
          }
          if (from < 4) {
            await m.addColumn(notes, notes.reminderTimestamp);
            await m.addColumn(notes, notes.reminderFired);
          }
            await customStatement('''
              CREATE TRIGGER IF NOT EXISTS notes_ai AFTER INSERT ON notes BEGIN
                INSERT INTO notes_fts(rowid, title, content) VALUES (new.id, new.title, new.content);
              END;
            ''');
            await customStatement('''
              CREATE TRIGGER IF NOT EXISTS notes_ad AFTER DELETE ON notes BEGIN
                INSERT INTO notes_fts(notes_fts, rowid, title, content) VALUES('delete', old.id, old.title, old.content);
              END;
            ''');
            await customStatement('''
              CREATE TRIGGER IF NOT EXISTS notes_au AFTER UPDATE ON notes BEGIN
                INSERT INTO notes_fts(notes_fts, rowid, title, content) VALUES('delete', old.id, old.title, old.content);
                INSERT INTO notes_fts(rowid, title, content) VALUES (new.id, new.title, new.content);
              END;
            ''');
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA journal_mode=WAL');
          await customStatement('PRAGMA foreign_keys=ON');

          // Ensure FTS5 table exists even if created via migration
          if (details.wasCreated) {
            try {
              await customStatement('''
                CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(
                  title, content, content=notes, content_rowid=id
                );
              ''');
              await customStatement('''
                CREATE TRIGGER IF NOT EXISTS notes_ai AFTER INSERT ON notes BEGIN
                  INSERT INTO notes_fts(rowid, title, content) VALUES (new.id, new.title, new.content);
                END;
              ''');
              await customStatement('''
                CREATE TRIGGER IF NOT EXISTS notes_ad AFTER DELETE ON notes BEGIN
                  INSERT INTO notes_fts(notes_fts, rowid, title, content) VALUES('delete', old.id, old.title, old.content);
                END;
              ''');
              await customStatement('''
                CREATE TRIGGER IF NOT EXISTS notes_au AFTER UPDATE ON notes BEGIN
                  INSERT INTO notes_fts(notes_fts, rowid, title, content) VALUES('delete', old.id, old.title, old.content);
                  INSERT INTO notes_fts(rowid, title, content) VALUES (new.id, new.title, new.content);
                END;
              ''');
            } catch (_) {
              // FTS5 not available on this platform, fallback to LIKE
            }
          }
        },
      );

  Future<void> _seedNoteColors() async {
    final colors = [
      NoteColorValuesCompanion(value: Value(0xFFFEF7E0), label: Value('暖黄')),
      NoteColorValuesCompanion(value: Value(0xFFE8F5E9), label: Value('淡绿')),
      NoteColorValuesCompanion(value: Value(0xFFE3F2FD), label: Value('淡蓝')),
      NoteColorValuesCompanion(value: Value(0xFFFCE4EC), label: Value('淡粉')),
      NoteColorValuesCompanion(value: Value(0xFFF3E5F5), label: Value('淡紫')),
      NoteColorValuesCompanion(value: Value(0xFFE0F7FA), label: Value('青')),
      NoteColorValuesCompanion(value: Value(0xFFFFF8E1), label: Value('淡橙')),
      NoteColorValuesCompanion(value: Value(0xFFEFEBE9), label: Value('淡棕')),
      NoteColorValuesCompanion(value: Value(0xFFE0E0E0), label: Value('灰色')),
      NoteColorValuesCompanion(value: Value(0xFFFFFFFF), label: Value('白色')),
    ];
    await batch((b) => b.insertAll(noteColorValues, colors));
  }
}
