import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../constants/app_sizes.dart';

/// The real "Signature Dish" wordmark. Natural artwork is 270 x 156; pass the
/// width the design calls for and the height follows.
class AppBrandLogo extends StatelessWidget {
  /// Width in design pixels (auth screens use 153, the splash uses 270).
  final double width;

  const AppBrandLogo({super.key, this.width = 153});

  static const double _ratio = AppAssets.logoH / AppAssets.logoW;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.brandLogo,
      width: width.w,
      height: (width * _ratio).w,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
