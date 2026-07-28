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
    '暖黄', '淡绿', '淡蓝', '淡粉', '淡紫',
    '青', '淡橙', '淡棕', '灰色', '白色',
  ];

  static Color backgroundColor(int colorValue, Brightness brightness) {
    final color = Color(colorValue);
    if (brightness == Brightness.dark) {
      return Color.lerp(color, Colors.black, 0.6)!;
    }
    return color;
  }

  static Color onBackgroundColor(int colorValue, Brightness brightness) {
    final luminance = _luminance(Color(colorValue));
    if (brightness == Brightness.dark) {
      return luminance > 0.3 ? Colors.black : Colors.white;
    }
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  static double _luminance(Color color) {
    return (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
  }
}
