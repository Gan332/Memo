import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:memo_app/data/database/app_database.dart';
import 'package:memo_app/domain/entities/note_entity.dart';
import 'package:memo_app/l10n/app_localizations.dart';
import 'package:memo_app/screens/add_edit_note_screen.dart';
import 'package:memo_app/state/providers/checklist_provider.dart';
import 'package:memo_app/state/providers/note_provider.dart';
import 'package:memo_app/state/providers/tag_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_database.dart';

Widget buildEditor({
  AppDatabase? db,
  NoteProvider? noteProvider,
  NoteEntity? note,
}) {
  final database = db ?? createTestDatabase();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: noteProvider ?? NoteProvider(db: database),
      ),
      ChangeNotifierProvider.value(value: TagProvider(db: database)),
      ChangeNotifierProvider.value(value: ChecklistProvider(db: database)),
    ],
    child: MaterialApp(
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      home: AddEditNoteScreen(note: note),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('AddEditNoteScreen', () {
    testWidgets('formatting toolbar hides when content loses focus', (
      tester,
    ) async {
      await tester.pumpWidget(buildEditor());
      await tester.pump();

      expect(find.byIcon(Icons.format_bold), findsNothing);

      final content = find.byType(TextField).at(1);
      await tester.tap(content);
      await tester.pump();

      expect(find.byIcon(Icons.format_bold), findsOneWidget);

      await tester.tap(find.byType(TextField).at(0));
      await tester.pump();

      expect(find.byIcon(Icons.format_bold), findsNothing);
    });

    testWidgets('formatting actions insert markdown and position cursor', (
      tester,
    ) async {
      await tester.pumpWidget(buildEditor());
      await tester.pump();
      final content = find.byType(TextField).at(1);
      await tester.tap(content);
      await tester.pump();

      Future<void> apply(
        IconData icon,
        String expected,
        int cursorOffset,
      ) async {
        final field = tester.widget<TextField>(content);
        field.controller!.text = 'hello';
        field.controller!.selection = const TextSelection(
          baseOffset: 0,
          extentOffset: 5,
        );
        await tester.pump();
        final button = find.byIcon(icon);
        await tester.ensureVisible(button);
        await tester.pump();
        await tester.tap(button);
        await tester.pump();

        final updated = tester.widget<TextField>(content);
        expect(updated.controller!.text, expected);
        expect(updated.controller!.selection.baseOffset, cursorOffset);
      }

      await apply(Icons.format_bold, '**hello**', 9);
      await apply(Icons.format_quote, '> hello', 7);
      await apply(Icons.title, '# hello', 2);
      await apply(Icons.format_list_bulleted, '- hello', 2);
      await apply(Icons.format_list_numbered, '1. hello', 3);
      await apply(Icons.link, '[hello](url)', 12);
    });

    testWidgets('content edits schedule auto-save for existing notes', (
      tester,
    ) async {
      final db = createTestDatabase();
      final noteProvider = NoteProvider(db: db);
      final now = DateTime.now();
      final id = await noteProvider.addNote(
        NoteEntity(
          title: 'Old Title',
          content: 'Old Content',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final row = noteProvider.notes.first;
      final note = NoteEntity(
        id: id,
        title: row.title,
        content: row.content,
        noteType: NoteType.values.byName(row.noteType),
        color: row.color,
        isPinned: row.isPinned,
        isArchived: row.isArchived,
        createdAt: DateTime.parse(row.createdAt),
        updatedAt: DateTime.parse(row.updatedAt),
      );

      await tester.pumpWidget(
        buildEditor(
          db: db,
          noteProvider: noteProvider,
          note: note,
        ),
      );
      await tester.pump();
      await tester.enterText(
        find.byType(TextField).at(1),
        'Updated Content',
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 100));

      expect(noteProvider.notes.first.title, 'Old Title');
      expect(noteProvider.notes.first.content, 'Updated Content');
    });
  });
}
