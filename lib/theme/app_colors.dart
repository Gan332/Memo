import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppColors {
  static const Color primarySeed = Color(0xFFFF8C00);

  static const List<int> notePalette = [
    0xFFFEF7E0,
    0xFFE8F5E9,
    0xFFE3F2FD,
    0xFFFCE4EC,
    0xFFF3E5F5,
    0xFFE0F7FA,
    0xFFFFF8E1,
    0xFFEFEBE9,
    0xFFE0E0E0,
    0xFFFFFFFF,
  ];

  static const List<String> notePaletteLabels = [
    '暖黄',
    '淡绿',
    '淡蓝',
    '淡粉',
    '淡紫',
    '青',
    '淡橙',
    '淡棕',
    '灰色',
    '白色',
  ];

  static const List<int> tagPalette = [
    0xFF42A5F5,
    0xFF66BB6A,
    0xFFFFA726,
    0xFFEF5350,
    0xFFAB47BC,
    0xFF26C6DA,
    0xFFEC407A,
    0xFF5C6BC0,
  ];

  static Color backgroundColor(int colorValue, Brightness brightness) {
    final color = Color(colorValue);
    if (brightness == Brightness.dark) {
      // Lerp towards a dark surface tone instead of pure black,
      // preserving more of the original hue while dimming sufficiently.
      const darkSurface = Color(0xFF1C1B1F);
      return Color.lerp(color, darkSurface, 0.45)!;
    }
    return color;
  }

  static Color onBackgroundColor(int colorValue, Brightness brightness) {
    final relativeLuminance = _relativeLuminance(Color(colorValue));
    if (brightness == Brightness.dark) {
      return relativeLuminance > 0.3 ? Colors.black : Colors.white;
    }
    return relativeLuminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// WCAG 2.1 relative luminance: https://www.w3.org/WAI/GL/wiki/Relative_luminance
  static double _relativeLuminance(Color color) {
    final r = _linearize(color.r);
    final g = _linearize(color.g);
    final b = _linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double channel) {
    if (channel <= 0.04045) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }
}
