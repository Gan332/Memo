import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppColors', () {
    test('notePalette has correct count', () {
      expect(AppColors.notePalette.length, 10);
      expect(AppColors.notePaletteLabels.length, 10);
    });

    test('backgroundColor returns correct color for light mode', () {
      final color = AppColors.backgroundColor(
        0xFFE8F5E9,
        Brightness.light,
      );
      expect(color.value, 0xFFE8F5E9);
    });

    test('onBackgroundColor returns readable text color', () {
      final lightOnColor = AppColors.onBackgroundColor(
        0xFFE8F5E9,
        Brightness.light,
      );
      // Should be dark text on light background
      expect(lightOnColor.computeLuminance(), lessThan(0.5));

      final darkOnColor = AppColors.onBackgroundColor(
        0xFF212121,
        Brightness.dark,
      );
      // Should be light text on dark background
      expect(darkOnColor.computeLuminance(), greaterThan(0.5));
    });
  });
}
