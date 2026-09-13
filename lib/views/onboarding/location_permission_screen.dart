import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../auth/signin_screen.dart';
import '../auth/signup_screen.dart';

/// Frame `Location allow.png` — the permission sheet sits on a dimmed sign-up
/// screen, so that is exactly what is rendered behind it rather than a
/// hand-faded stand-in.
class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  int _selected = 0;

  static const List<String> _options = [
    'Standort immer zulassen',
    'Nur während der Nutzung der App zulassen.',
    'Standort nicht zulassen',
  ];

  Future<void> _proceed() async {
    if (_selected != 2) {
      try {
        await Geolocator.requestPermission();
      } catch (_) {
        /* Discovery remains available without location. */
      }
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);

    return Stack(
      children: [
        // Real screen underneath, inert.
        const IgnorePointer(child: SignUpScreen()),

        // Scrim
        Container(
          color: Colors.black.withValues(alpha: 0.45),
        ).animate().fadeIn(duration: 320.ms),

        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            // The sheet is its own Material: the radio rows use InkWell, and
            // this screen sits above another Scaffold rather than owning one.
            child:
                Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.w),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 24.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(child: _PinBadge()),
                            SizedBox(height: 22.h),
                            Text(
                              'Standortzugriff erlauben?',
                              style: AppTextStyles.body(
                                size: AppFontSizes.titleLarge,
                                color: AppColors.textDark,
                                weight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 18.h),
                            ...List.generate(_options.length, (i) {
                              final selected = _selected == i;
                              return InkWell(
                                onTap: () => setState(() => _selected = i),
                                borderRadius: BorderRadius.circular(8.w),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 7.h),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        margin: EdgeInsets.only(top: 2.h),
                                        width: 15.w,
                                        height: 15.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selected
                                                ? AppColors.primary
                                                : AppColors.cyan,
                                            width: 1.4,
                                          ),
                                        ),
                                        child: Center(
                                          child: AnimatedScale(
                                            scale: selected ? 1 : 0,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            curve: Curves.easeOutBack,
                                            child: Container(
                                              width: 7.w,
                                              height: 7.w,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          _options[i],
                                          style: AppTextStyles.body(
                                            size: AppFontSizes.labelSmall,
                                            height: 1.45,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            SizedBox(height: 24.h),
                            CustomButton(
                              text: 'Weitermachen',
                              onPressed: _proceed,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 120.ms)
                    .scale(
                      begin: const Offset(0.94, 0.94),
                      end: const Offset(1, 1),
                      duration: 380.ms,
                      curve: Curves.easeOutBack,
                    ),
          ),
        ),
      ],
    );
  }
}

/// Concentric rings behind the pin, with the outer ring quietly pulsing.
class _PinBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76.w,
      height: 76.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 0.9,
                end: 1.06,
                duration: 1800.ms,
                curve: Curves.easeInOut,
              ),
          Container(
            width: 58.w,
            height: 58.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 22.w,
            ),
          ),
        ],
      ),
    );
  }
}
