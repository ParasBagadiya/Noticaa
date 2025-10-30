import 'dart:ui';

class ColorUtils {
  static int colorToInt(Color color) {
    return color.alpha << 24 | color.red << 16 | color.green << 8 | color.blue;
  }

  static Color intToColor(int value) {
    return Color(value);
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withAlpha((color.alpha * opacity).round());
  }
}
