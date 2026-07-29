import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:memo_app/screens/home_screen.dart';
import 'package:memo_app/state/providers/note_provider.dart';
import 'package:memo_app/state/providers/tag_provider.dart';
import 'package:memo_app/state/providers/checklist_provider.dart';
import 'package:memo_app/state/providers/theme_provider.dart';

import '../helpers/test_database.dart';

void main() {
  group('HomeScreen', () {
    Widget buildTestWidget() {
      final db = createTestDatabase();
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => NoteProvider(db: db)),
          ChangeNotifierProvider(create: (_) => TagProvider(db: db)),
          ChangeNotifierProvider(create: (_) => ChecklistProvider(db: db)),
        ],
        child: MaterialApp(
          home: const HomeScreen(),
        ),
      );
    }

    testWidgets('should display app bar with title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('备忘录'), findsOneWidget);
    });

    testWidgets('should show empty state when no notes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('还没有笔记'), findsOneWidget);
      expect(find.text('点击右下角 + 创建第一条笔记'), findsOneWidget);
    });

    testWidgets('should show search icon in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should show filter icon in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should show FAB for creating notes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should enter search mode when search icon tapped',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('搜索笔记...'), findsOneWidget);
    });
  });
}
