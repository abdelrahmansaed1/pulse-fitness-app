import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary accent — volt green (exact match from design)
  static const Color volt        = Color(0xFFCCFF00);
  static const Color voltDim     = Color(0xFF99BF00);
  static const Color voltGlow    = Color(0x40CCFF00);

  // Backgrounds
  static const Color bgPrimary   = Color(0xFF08080A);
  static const Color bgSecondary = Color(0xFF0C0C0E);
  static const Color bgCard      = Color(0xFF111114);
  static const Color bgElevated  = Color(0xFF1A1A1F);

  // Borders
  static const Color border      = Color(0xFF27272A);
  static const Color borderDim   = Color(0xFF18181B);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted     = Color(0xFF52525B);

  // Semantic
  static const Color cyan    = Color(0xFF00E5FF);
  static const Color red     = Color(0xFFEF4444);
  static const Color amber   = Color(0xFFF59E0B);
  static const Color emerald = Color(0xFF10B981);

  // Chart bar colors
  static const List<Color> chartBars = [
    Color(0xFF3F3F46),
    Color(0xFF3F3F46),
    Color(0xFF3F3F46),
    Color(0xFF3F3F46),
    Color(0xFF3F3F46),
    Color(0xFFCCFF00), // today always volt
    Color(0xFF3F3F46),
  ];
}