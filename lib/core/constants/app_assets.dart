/// Cut-outs lifted from the Figma frames. Each constant carries the size and
/// frame position it was measured at (design space is 393 x 852), so screens can
/// place it with `AppSizes` and land exactly where the design puts it.
///
/// The full-frame Figma exports still live in `assets/` for reference but are no
/// longer bundled — only `assets/img/` ships with the app.
class AppAssets {
  AppAssets._();

  static const String _img = 'assets/img/';

  // Brand — natural size 270 x 156
  static const String brandLogo = '${_img}brand_logo.png';
  static const double logoW = 270, logoH = 156;

  // Decorative shapes
  /// Top-left yellow wave, natural 267 x 210, sits at (0, 0).
  /// Slide 2 uses the same artwork mirrored and pinned to the right edge.
  static const String waveTop = '${_img}wave_top.png';
  static const double waveW = 267, waveH = 210;

  /// Rounded yellow leaf, onboarding scale: 143 x 241 at (0, 2).
  static const String blobLeaf = '${_img}blob_leaf.png';
  static const double blobLeafW = 143, blobLeafH = 241;

  /// Same leaf at the smaller auth scale: 115 x 206 at (0, 0).
  static const String blobLeafAuth = '${_img}blob_leaf_auth.png';
  static const double blobLeafAuthW = 115, blobLeafAuthH = 206;

  /// Cyan action blob in the bottom-right corner, 134 x 219 at (259, 635) —
  /// so it overhangs the frame's bottom edge by 2.
  ///
  /// Composed from the original `Vector.png` + `Vector (1).png` exports rather
  /// than lifted from a frame: the frames all have the arrow drawn inside the
  /// blob, and keying it out left an arrow-shaped hole in the artwork.
  static const String blobCyan = '${_img}blob_cyan.png';
  static const double blobCyanW = 134, blobCyanH = 219, blobCyanOverhang = 2;

  // Auth garnish
  /// Herb flakes, 112 x 114 at (281, 0).
  static const String decoHerbs = '${_img}deco_herbs.png';
  static const double herbsW = 112, herbsH = 114;

  /// Chilli/spice scatter, 122 x 122 at (0, 730).
  static const String decoSpice = '${_img}deco_spice.png';
  static const double spiceW = 122, spiceH = 122;

  /// Faded skewer platter, 137 x 160 at (256, 675).
  static const String decoSkewers = '${_img}deco_skewers.png';
  static const double skewersW = 137, skewersH = 160;

  // Restaurant-owner home decoration. These transparent PNGs are deliberately
  // kept separate from the cards so they can be positioned responsively and
  // never intercept taps or scrolling.
  static const String homeDecoSpice = '${_img}home_deco_spice.png';
  static const String homeDecoCoffee = '${_img}home_deco_coffee.png';
  static const String homeDecoHerbs = '${_img}home_deco_herbs.png';
  static const String homeDecoOnion = '${_img}home_deco_onion.png';

  /// Stand-in for the live map until a map SDK is wired in — this is a real
  /// background image, so `BoxFit.cover` is correct here.
  static const String mapPlaceholder = '${_img}map_placeholder.jpg';

  // Onboarding slide 1 — "Entdecken Sie unsere Spezialitäten"
  static const String onb1Coffee =
      '${_img}onb1_coffee.png'; // 200 x 233 @ (193, 114)
  static const String onb1Beef = '${_img}onb1_beef.png'; // 185 x 276 @ (0, 503)
  static const String onb1Spice =
      '${_img}onb1_spice.png'; // 113 x 109 @ (280, 486)

  // Onboarding slide 2 — "Finde Gerichte, für die sich eine Reise lohnt"
  static const String onb2Pan = '${_img}onb2_pan.png'; // 211 x 276 @ (0, 108)
  static const String onb2Skewers =
      '${_img}onb2_skewers.png'; // 193 x 221 @ (0, 554)

  // Onboarding slide 3 — "Vertrauenswürdige Bewertungen und echte Erfahrungen"
  static const String onb3Shake =
      '${_img}onb3_shake.png'; // 155 x 271 @ (238, 77)
  static const String onb3Pancakes =
      '${_img}onb3_pancakes.png'; // 190 x 219 @ (0, 550)
  static const String onb3Garnish =
      '${_img}onb3_garnish.png'; // 95 x 100 @ (298, 498)
}
