import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'app_motion.dart';

/// The thin chevron the inner auth screens carry in the top-left corner.
/// Floats over the scroll view so it never shifts the measured form spacing.
class AuthBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AuthBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12.w,
      top: 8.h,
      child: IconButton(
        onPressed: onTap ?? () => Navigator.maybePop(context),
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 18.w,
          color: AppColors.textDark,
        ),
        splashRadius: 22.w,
      ).fadeSlideX(offset: -0.4, duration: const Duration(milliseconds: 350)),
    );
  }
}
