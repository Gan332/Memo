import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'data/database/app_database.dart';
import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';
import 'state/providers/note_provider.dart';
import 'state/providers/tag_provider.dart';
import 'state/providers/checklist_provider.dart';
import 'state/providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  final db = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider(db: db)),
        ChangeNotifierProvider(create: (_) => TagProvider(db: db)),
        ChangeNotifierProvider(create: (_) => ChecklistProvider(db: db)),
      ],
      child: MemoApp(db: db),
    ),
  );
}

class MemoApp extends StatefulWidget {
  final AppDatabase db;
  const MemoApp({super.key, required this.db});

  @override
  State<MemoApp> createState() => _MemoAppState();
}

class _MemoAppState extends State<MemoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check for missed reminders — providers are now ancestors,
      // so context.read works correctly from lifecycle methods.
      context.read<NoteProvider>().checkPendingReminders();
    }
    if (state == AppLifecycleState.detached) {
      widget.db.close();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return DynamicColorBuilder(
          builder: (lightColorScheme, darkColorScheme) {
            final lightScheme =
                themeProvider.useDynamicColor ? lightColorScheme : null;
            final darkScheme =
                themeProvider.useDynamicColor ? darkColorScheme : null;

            return MaterialApp(
              title: '备忘录',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(lightScheme),
              darkTheme: AppTheme.darkTheme(darkScheme),
              themeMode: themeProvider.themeMode,
              locale: themeProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}
