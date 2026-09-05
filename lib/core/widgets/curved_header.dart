import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'app_brand_logo.dart';
import 'app_motion.dart';
import 'frame_positioned.dart';

/// Home / explore header. The design (`Home.jpg`) puts a flat #FFE88B band
/// across the top down to y 143, herb specks in the right corner, and lets the
/// search bar straddle the band's bottom edge.
class CurvedHeader extends StatelessWidget {
  /// Search bar + filter pills. Overlaps the yellow band the way the design does.
  final Widget? bottomChild;
  final VoidCallback? onLocationTap;

  const CurvedHeader({super.key, this.bottomChild, this.onLocationTap});

  /// Yellow runs to design y 143; the status bar is inside that band.
  static const double _bandBottom = 143;

  /// How far the search bar rides up onto the yellow.
  static const double _overlap = 16;

  @override
  Widget build(BuildContext context) {
    final bandHeight = _bandBottom.h;

    return Column(
      children: [
        SizedBox(
          height: bandHeight,
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: AppColors.yellow)),
              FramePositioned.art(
                AppAssets.decoHerbs,
                right: 0,
                top: 0,
                width: AppAssets.herbsW,
                height: AppAssets.herbsH,
                opacity: 0.75,
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const AppBrandLogo(width: 78).fadeSlideX(offset: -0.2),
                      GestureDetector(
                        onTap: onLocationTap,
                        child: Container(
                          padding: EdgeInsets.all(7.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.my_location,
                            color: AppColors.textDark,
                            size: 19.w,
                          ),
                        ),
                      ).popIn(delay: const Duration(milliseconds: 120)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // No padding here — the caller decides which rows hug the screen edge
        // (the filter pills scroll off it, the search bar does not).
        if (bottomChild != null)
          Transform.translate(
            offset: Offset(0, -_overlap.h),
            child: bottomChild!,
          ),
      ],
    );
  }
}
