import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppTypography', () {
    test('headlineSmall has correct font size', () {
      expect(AppTypography.headlineSmall.fontSize, 24);
      expect(AppTypography.headlineSmall.fontWeight, FontWeight.w600);
    });

    test('bodyLarge has correct properties', () {
      expect(AppTypography.bodyLarge.fontSize, 16);
      expect(AppTypography.bodyLarge.fontWeight, FontWeight.w400);
    });

    test('labelMedium has correct properties', () {
      expect(AppTypography.labelMedium.fontSize, 12);
      expect(AppTypography.labelMedium.fontWeight, FontWeight.w500);
    });
  });
}
