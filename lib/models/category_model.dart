import 'package:flutter/material.dart';
import 'package:noticaa/utils/color_utils.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final IconData icon; // Add icon field

  Category({
    required this.id,
    required this.name,
    required this.color,// Add color
    required this.icon, // Add to constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': ColorUtils.colorToInt(color),
      'icon': icon.codePoint, // Store icon code point
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: ColorUtils.intToColor(map['color']),
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'), // Restore icon
    );
  }
}
