import 'dart:ui';

class ColorUtils {
  static int colorToInt(Color color) {
    final a = (color.a * 255.0).round() & 0xff;
    final r = (color.r * 255.0).round() & 0xff;
    final g = (color.g * 255.0).round() & 0xff;
    final b = (color.b * 255.0).round() & 0xff;
    return a << 24 | r << 16 | g << 8 | b;
  }

  static Color intToColor(int value) {
    return Color(value);
  }

  static Color withOpacity(Color color, double opacity) {
    final alpha = (color.a * opacity).clamp(0.0, 1.0);
    return color.withValues(alpha: alpha);
  }
}