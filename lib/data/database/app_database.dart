import 'package:drift/drift.dart';

part 'app_database.g.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get noteType => text().withDefault(const Constant('text'))();
  IntColumn get color => integer().withDefault(const Constant(0xFFFEF7E0))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
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
  List<Set<Column>> get uniqueKeys => [{name}];
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
  TextColumn get text => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class NoteColorValues extends Table {
  IntColumn get value => integer()();
  TextColumn get label => text()();

  @override
  Set<Column> get primaryKey => {value};
}

@DriftDatabase(tables: [Notes, Tags, NoteTags, ChecklistItems, NoteColorValues])
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;

  AppDatabase._internal() : super(_openConnection());

  factory AppDatabase() => _instance ??= AppDatabase._internal();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedNoteColors();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations go here
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA journal_mode=WAL');
          await customStatement('PRAGMA foreign_keys=ON');
        },
      );

  Future<void> _seedNoteColors() async {
    final colors = [
      NoteColorValuesCompanion.insert(
          value: const Color(0xFFFEF7E0).value, label: '暖黄'),
      NoteColorValuesCompanion.insert(
          value: const Color(0xFFE8F5E9).value, label: '淡绿'),
      NoteColorValuesCompanion.insert(
          value: const Color(0xFFE3F2FD).value, label: '淡蓝'),
      NoteColorValuesCompanion.insert(
          value: const Color(0xFFFCE4EC).value, label: '淡粉'),
      NoteColorValuesCompanion.insert(
          value: const Color(0xFFF3E5F5).value, label: '淡紫'),
      NoteColorValuesCompanion.insert(
          value: const Color(0xFFE0F7FA).value, label: '青'),
      NoteColorValuesCompanion.insert(
          value: const Color(0xFFFFF8E1).value, label: '淡橙'),
      NoteColorValuesCompanion.insert(
          value: const Color(0xFFEFEBE9).value, label: '淡棕'),
      NoteColorValuesCompanion.insert(
          value: const Color(0xFFE0E0E0).value, label: '灰色'),
      NoteColorValuesCompanion.insert(
          value: const int.parse('FFFFFFFF', radix: 16), label: '白色'),
    ];
    await batch((b) => b.insertAll(noteColorValues, colors));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = dbFolder.child('memo_app.db');

    // For mobile and desktop, use native sqlite3
    final driftDatabaseFile = file;
    final executor = NativeDatabase(driftDatabaseFile);

    return executor;
  });
}
