import 'package:flutter/material.dart';

class ProfileColors {
  static const List<Color> colors = [
    Color(0xFF3498DB),
    Color(0xFF2ECC71),
    Color(0xFFE74C3C),
    Color(0xFF9B59B6),
    Color(0xFFF1C40F),
    Color(0xFF1ABC9C),
    Color(0xFFE67E22),
    Color(0xFF34495E),
    Color(0xFFD35400),
    Color(0xFF27AE60),
    Color(0xFF8E44AD),
    Color(0xFFC0392B),
    Color(0xFF16A085),
    Color(0xFF7F8C8D),
    Color(0xFF2C3E50),
    Color(0xFFFF5733),
  ];

  static Color getColorByIndex(int index) {
    if (index < 0 || index >= colors.length) {
      return colors[0];
    }
    return colors[index];
  }

  static int getIndexByColor(Color color) {
    final colorValue = color.toARGB32();
    for (int i = 0; i < colors.length; i++) {
      if (colors[i].toARGB32() == colorValue) {
        return i;
      }
    }
    return 0;
  }

  static List<Color> getAllColors() {
    return colors;
  }
}
