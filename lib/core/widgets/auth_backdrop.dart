import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import 'app_motion.dart';
import 'frame_positioned.dart';

/// The four corner decorations every auth screen shares, at the exact frame
/// positions measured off the Figma exports:
///
///   yellow leaf   115 x 206 @ (0, 0)
///   herb flakes   112 x 114 @ (281, 0)
///   spice scatter 122 x 122 @ (0, 730)
///   skewer plate  137 x 160 @ (256, 675)
///
/// Everything is `IgnorePointer` so the form on top stays fully tappable.
class AuthBackdrop extends StatelessWidget {
  final Widget child;

  /// Sign-up and the screens below it drop the skewer plate lower; keeping the
  /// flag lets one widget serve every auth screen.
  final bool showSkewers;
  final bool showSpice;
  final bool animate;

  const AuthBackdrop({
    super.key,
    required this.child,
    this.showSkewers = true,
    this.showSpice = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final leaf = FramePositioned.art(
      AppAssets.blobLeafAuth,
      left: 0,
      top: 0,
      width: AppAssets.blobLeafAuthW,
      height: AppAssets.blobLeafAuthH,
      effect: animate
          ? (c) => c.fadeSlideX(offset: -0.25, duration: const Duration(milliseconds: 800))
          : null,
    );
    final herbs = FramePositioned.art(
      AppAssets.decoHerbs,
      right: 0,
      top: 0,
      width: AppAssets.herbsW,
      height: AppAssets.herbsH,
      effect: animate ? (c) => c.fadeSoft(delay: const Duration(milliseconds: 120)) : null,
    );
    final spice = FramePositioned.art(
      AppAssets.decoSpice,
      left: 0,
      bottom: 0,
      width: AppAssets.spiceW,
      height: AppAssets.spiceH,
      effect: animate ? (c) => c.fadeSoft(delay: const Duration(milliseconds: 220)) : null,
    );
    final skewers = FramePositioned.art(
      AppAssets.decoSkewers,
      right: 0,
      bottom: 18,
      width: AppAssets.skewersW,
      height: AppAssets.skewersH,
      effect: animate
          ? (c) => c.fadeSlideX(offset: 0.2, duration: const Duration(milliseconds: 900))
          : null,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          leaf,
          herbs,
          if (showSpice) spice,
          if (showSkewers) skewers,
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
