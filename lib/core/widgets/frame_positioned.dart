import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

/// `Positioned`, but every number is a coordinate read straight off the 393 x 852
/// Figma frame. Keeps screen code looking like the design spec.
class FramePositioned extends StatelessWidget {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  final Widget child;

  const FramePositioned({
    super.key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    required this.child,
  });

  /// Places an image cut-out at its measured frame position and natural size.
  ///
  /// Pass entrance animations through [effect] rather than chaining them onto
  /// the result: the returned widget is a `Positioned`, and wrapping a
  /// `Positioned` turns it back into an ordinary Stack child that ignores every
  /// coordinate on it.
  factory FramePositioned.art(
    String asset, {
    double? left,
    double? top,
    double? right,
    double? bottom,
    required double width,
    required double height,
    bool mirrored = false,
    double opacity = 1,
    Widget Function(Widget child)? effect,
  }) {
    Widget image = Image.asset(asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium);
    if (mirrored) {
      image = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scaleByDouble(-1.0, 1.0, 1.0, 1.0),
        child: image,
      );
    }
    if (opacity < 1) image = Opacity(opacity: opacity, child: image);
    if (effect != null) image = effect(image);
    return FramePositioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: IgnorePointer(child: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left?.w,
      // `top` is an absolute frame position, so it absorbs the device's extra
      // height proportionally; `bottom` is measured from the screen edge and
      // scales straight.
      top: top?.y,
      right: right?.w,
      bottom: bottom?.h,
      width: width?.w,
      height: height?.h,
      child: child,
    );
  }
}
