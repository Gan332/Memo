import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme has Material 3 enabled', () {
      final theme = AppTheme.lightTheme();
      expect(theme.useMaterial3, true);
    });

    test('darkTheme has Material 3 enabled', () {
      final theme = AppTheme.darkTheme();
      expect(theme.useMaterial3, true);
      expect(theme.brightness, Brightness.dark);
    });

    test('lightTheme has correct scaffold background', () {
      final theme = AppTheme.lightTheme();
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF5F5F5));
    });

    test('darkTheme has correct scaffold background', () {
      final theme = AppTheme.darkTheme();
      expect(theme.scaffoldBackgroundColor, const Color(0xFF1C1B1F));
    });

    test('themes accept custom color schemes', () {
      final customScheme = ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: Brightness.light,
      );

      final theme = AppTheme.lightTheme(customScheme);
      expect(theme.colorScheme.primary, customScheme.primary);
    });
  });
}
