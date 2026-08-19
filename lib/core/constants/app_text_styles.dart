import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

/// Three faces carry the whole design. Each was picked by rendering candidates
/// at the width the Figma frames actually measure and keeping the lowest
/// pixel difference against the exports:
///
///   Kaushan Script — teal onboarding headlines, ~24px over a 36px line
///   Lora SemiBold  — the serif screen headings, ~18px
///   Urbanist       — everything else, ~14px over a 21px line
///
/// All three are bundled (see `pubspec.yaml`) rather than fetched at runtime,
/// so the first launch renders the real faces instead of system fallbacks.
/// Urbanist and Lora are variable fonts, so weight is set through
/// `fontVariations` as well as `fontWeight`.
class AppTextStyles {
  AppTextStyles._();

  static const String scriptFamily = 'KaushanScript';
  static const String serifFamily = 'Lora';
  static const String sansFamily = 'Urbanist';

  static List<FontVariation> _wght(FontWeight w) => [FontVariation('wght', w.value.toDouble())];

  /// Onboarding headline. Measured: 2 lines, 36px line pitch, #0097B0.
  static TextStyle script({double size = 24, Color color = AppColors.primary}) => TextStyle(
        fontFamily: scriptFamily,
        fontSize: size.sp,
        color: color,
        height: 1.5,
      );

  /// Bold serif heading, e.g. "Willkommen bei Signature Dish".
  static TextStyle heading({
    double size = 18,
    Color color = AppColors.textDark,
    FontWeight weight = FontWeight.w600,
  }) =>
      TextStyle(
        fontFamily: serifFamily,
        fontSize: size.sp,
        fontWeight: weight,
        fontVariations: _wght(weight),
        color: color,
        height: 1.25,
      );

  /// Paragraph copy — 14px over a 21px line, #858585.
  static TextStyle body({
    double size = 14,
    Color color = AppColors.textGrey,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
  }) =>
      TextStyle(
        fontFamily: sansFamily,
        fontSize: size.sp,
        color: color,
        fontWeight: weight,
        fontVariations: _wght(weight),
        height: height,
      );

  /// Labels, buttons, links.
  static TextStyle label({
    double size = 14,
    Color color = AppColors.textDark,
    FontWeight weight = FontWeight.w500,
    TextDecoration? decoration,
  }) =>
      TextStyle(
        fontFamily: sansFamily,
        fontSize: size.sp,
        color: color,
        fontWeight: weight,
        fontVariations: _wght(weight),
        decoration: decoration,
        height: 1.3,
      );
}
