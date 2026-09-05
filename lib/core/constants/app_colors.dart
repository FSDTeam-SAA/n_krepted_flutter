import 'package:flutter/material.dart';

/// Every value here was sampled straight out of the Figma frames in `assets/`.
class AppColors {
  // Brand
  static const Color primary = Color(0xFF0097B0); // buttons, titles, active dot
  static const Color primaryDark = Color(0xFF007E93);
  static const Color primaryLight = Color(0xFFDFF2F5);
  static const Color cyan = Color(
    0xFF6CD5E7,
  ); // onboarding blob + input borders
  static const Color cyanOutline = Color(
    0xFF3A4E9B,
  ); // thin ink line around the blob
  static const Color yellow = Color(0xFFFFE88B); // splash background + waves

  // Surfaces
  static const Color background = Colors.white;
  static const Color cardWhite = Colors.white;
  static const Color cardBorder = Color(0xFFEDEDED);
  static const Color divider = Color(0xFFEDEDED);
  static const Color inputBorder = cyan;
  static const Color inputFill = Colors.white;

  // Type
  static const Color textDark = Color(0xFF1A1A1A); // serif headings
  static const Color textBody = Color(0xFF4A4A4A);
  static const Color textGrey = Color(0xFF858585); // paragraph copy
  static const Color textMuted = Color(0xFF727272); // onboarding paragraph copy
  static const Color textLightGrey = Color(0xFFB1B1B1); // input hints
  static const Color dotInactive = Color(0xFFD9D9D9);

  // Accents
  static const Color yellowAccent = Color(0xFFFFDE59);
  static const Color orangeAccent = Color(0xFFF59E0B);
  static const Color starYellow = Color(0xFFFFB800);
  static const Color badgeRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color cardYellow = Color(0xFFFFF9E6);
}
