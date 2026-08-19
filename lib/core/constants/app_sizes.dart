import 'package:flutter/widgets.dart';

/// Maps the Figma frame (393 x 852 — iPhone 15 Pro) onto whatever screen we are
/// actually running on, so every measurement taken off the design can be written
/// down verbatim and still land in the right place on any device.
///
/// Call [AppSizes.init] once per frame from the root builder before anything
/// reads `.w` / `.h` / `.sp`.
class AppSizes {
  AppSizes._();

  static const double designWidth = 393;
  static const double designHeight = 852;

  static double screenWidth = designWidth;
  static double screenHeight = designHeight;
  static double topInset = 0;
  static double bottomInset = 0;

  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    // On Android the very first frame can report Size.zero before the window
    // metrics arrive. Taking that would make every `.w` collapse to 0 and the
    // screen render empty, so hold the last good values (initially the design
    // frame itself) until a real size shows up.
    if (mq.size.width <= 0 || mq.size.height <= 0) return;
    screenWidth = mq.size.width;
    screenHeight = mq.size.height;
    topInset = mq.padding.top;
    bottomInset = mq.padding.bottom;
  }

  /// Horizontal scale factor, also used for anything that must stay square
  /// (radii, icon sizes, type) so circles do not turn into ellipses.
  static double get scale => screenWidth / designWidth;

  /// Vertical scale factor. Only for full-height layouts that should stretch.
  static double get scaleY => screenHeight / designHeight;

  static double w(double v) => v * scale;

  /// Sizes and gaps: scaled by width so artwork keeps its aspect ratio instead
  /// of being squashed on a taller phone.
  static double h(double v) => v * scale;

  /// Vertical *position* measured from the top of the frame. Whatever height
  /// this device has beyond the scaled design frame is spread proportionally,
  /// so y=0 stays at the top, y=852 stays at the bottom, and everything in
  /// between keeps its relative place.
  static double y(double v) => v * scale + slack * (v / designHeight);

  static double sp(double v) => v * scale.clamp(0.85, 1.25);

  /// Extra vertical room this device has compared with the design frame.
  static double get slack => screenHeight - designHeight * scale;
}

extension AppSizesNum on num {
  /// Horizontal design pixels.
  double get w => AppSizes.w(toDouble());

  /// Vertical design pixels — sizes and gaps.
  double get h => AppSizes.h(toDouble());

  /// Vertical design pixels — absolute position from the top of the frame.
  double get y => AppSizes.y(toDouble());

  /// Design type size.
  double get sp => AppSizes.sp(toDouble());
}
