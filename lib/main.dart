import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'state/providers/note_provider.dart';
import 'state/providers/tag_provider.dart';
import 'state/providers/checklist_provider.dart';
import 'state/providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MemoApp());
}

class MemoApp extends StatelessWidget {
  const MemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => TagProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return DynamicColorBuilder(
            builder: (lightColorScheme, darkColorScheme) {
              final lightScheme = themeProvider.useDynamicColor
                  ? lightColorScheme
                  : null;
              final darkScheme = themeProvider.useDynamicColor
                  ? darkColorScheme
                  : null;

              return MaterialApp(
                title: '备忘录',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme(lightScheme),
                darkTheme: AppTheme.darkTheme(darkScheme),
                themeMode: themeProvider.themeMode,
                locale: const Locale('zh', 'CN'),
                localizationsDelegates: const [
                  DefaultMaterialLocalizations.delegate,
                  DefaultWidgetsLocalizations.delegate,
                ],
                home: const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
