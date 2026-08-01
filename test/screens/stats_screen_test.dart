import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:memo_app/data/database/app_database.dart';
import 'package:memo_app/domain/entities/note_entity.dart';
import 'package:memo_app/l10n/app_localizations.dart';
import 'package:memo_app/screens/stats_screen.dart';
import 'package:memo_app/state/providers/note_provider.dart';
import 'package:memo_app/state/providers/tag_provider.dart';

import '../helpers/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late AppDatabase db;
  late NoteProvider noteProvider;
  late TagProvider tagProvider;

  setUp(() async {
    db = createTestDatabase();
    noteProvider = NoteProvider(db: db);
    tagProvider = TagProvider(db: db);
    await noteProvider.loadNotes();
    await tagProvider.loadTags();
  });

  tearDown(() async {
    noteProvider.dispose();
    tagProvider.dispose();
    await db.close();
  });

  Widget buildApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: noteProvider),
        ChangeNotifierProvider.value(value: tagProvider),
      ],
      child: MaterialApp(
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StatsScreen(),
      ),
    );
  }

  testWidgets('shows aggregated statistics for notes', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();
    await noteProvider.addNote(
      NoteEntity(
        title: 'Active Pinned',
        content: 'hello world',
        isPinned: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await noteProvider.addNote(
      NoteEntity(
        title: 'Checklist',
        content: '',
        noteType: NoteType.checklist,
        isArchived: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('数据统计'), findsOneWidget);
    expect(find.text('总览'), findsOneWidget);
    // Total / active / pinned counts
    expect(find.text('2'), findsWidgets);
    expect(find.text('1'), findsWidgets);
    // Content volume
    expect(find.text('总字数'), findsOneWidget);
    expect(find.text('总字符'), findsOneWidget);
    // Type distribution
    expect(find.text('1 篇 (50%)'), findsNWidgets(2));
    expect(find.text('0 篇 (0%)'), findsOneWidget);
    // Tag distribution empty state
    expect(find.text('暂无标签'), findsOneWidget);
  });

  testWidgets('shows pending reminder count', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();
    await noteProvider.addNote(
      NoteEntity(
        title: 'Reminder',
        content: 'todo',
        reminderTimestamp: now.add(const Duration(hours: 1)).millisecondsSinceEpoch,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('待提醒'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
  });
}
