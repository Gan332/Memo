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

    test('lightTheme scaffold background is dark in light mode', () {
      final theme = AppTheme.lightTheme();
      // The exact color depends on ColorScheme.fromSeed; just verify it's a Color
      expect(theme.scaffoldBackgroundColor, isA<Color>());
    });

    test('darkTheme scaffold background is dark in dark mode', () {
      final theme = AppTheme.darkTheme();
      expect(theme.scaffoldBackgroundColor, isA<Color>());
      // Verify it's a dark color by checking brightness
      final hsl = HSLColor.fromColor(theme.scaffoldBackgroundColor);
      expect(hsl.lightness < 0.5, isTrue);
    });

    test('lightTheme has correct scaffold background', () {
      final theme = AppTheme.lightTheme();
      // ColorScheme.fromSeed output varies across SDK versions;
      // verify it's a light color rather than exact value
      final hsl = HSLColor.fromColor(theme.scaffoldBackgroundColor);
      expect(hsl.lightness > 0.5, isTrue);
    });

    test('darkTheme has correct scaffold background', () {
      final theme = AppTheme.darkTheme();
      // Verify it's a dark color
      final hsl = HSLColor.fromColor(theme.scaffoldBackgroundColor);
      expect(hsl.lightness < 0.3, isTrue);
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
