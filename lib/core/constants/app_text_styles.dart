import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

/// Central font-size scale for every piece of text in the Flutter app.
///
/// Change a value here to update every text style that uses that size. The
/// extra half-step values preserve the current design while keeping all size
/// decisions in one place.
class AppFontSizes {
  AppFontSizes._();

  static const double micro = 9;
  static const double tiny = 10;
  static const double tinyPlus = 10.5;
  static const double captionSmall = 11;
  static const double caption = 11.5;
  static const double small = 12;
  static const double smallPlus = 12.5;
  static const double authBody = 12.6;
  static const double labelSmall = 13;
  static const double labelMedium = 13.5;
  static const double body = 14;
  static const double bodyLarge = 14.5;
  static const double button = 15;
  static const double subtitle = 16;
  static const double titleSmall = 17;
  static const double title = 18;
  static const double titleLarge = 19;
  static const double headingSmall = 20;
  static const double heading = 22;
  static const double headingLarge = 23;
  static const double displaySmall = 24;
  static const double display = 25;
}

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

  static List<FontVariation> _wght(FontWeight w) => [
    FontVariation('wght', w.value.toDouble()),
  ];

  /// Onboarding headline. Measured: 2 lines, 36px line pitch, #0097B0.
  static TextStyle script({
    double size = AppFontSizes.displaySmall,
    Color color = AppColors.primary,
  }) => TextStyle(
    fontFamily: scriptFamily,
    fontSize: size.sp,
    color: color,
    height: 1.5,
  );

  /// Bold serif heading, e.g. "Willkommen bei Signature Dish".
  static TextStyle heading({
    double size = AppFontSizes.title,
    Color color = AppColors.textDark,
    FontWeight weight = FontWeight.w600,
  }) => TextStyle(
    fontFamily: serifFamily,
    fontSize: size.sp,
    fontWeight: weight,
    fontVariations: _wght(weight),
    color: color,
    height: 1.25,
  );

  /// Paragraph copy — 14px over a 21px line, #858585.
  static TextStyle body({
    double size = AppFontSizes.body,
    Color color = AppColors.textGrey,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
  }) => TextStyle(
    fontFamily: sansFamily,
    fontSize: size.sp,
    color: color,
    fontWeight: weight,
    fontVariations: _wght(weight),
    height: height,
  );

  /// Labels, buttons, links.
  static TextStyle label({
    double size = AppFontSizes.body,
    Color color = AppColors.textDark,
    FontWeight weight = FontWeight.w500,
    TextDecoration? decoration,
  }) => TextStyle(
    fontFamily: sansFamily,
    fontSize: size.sp,
    color: color,
    fontWeight: weight,
    fontVariations: _wght(weight),
    decoration: decoration,
    height: 1.3,
  );
}
