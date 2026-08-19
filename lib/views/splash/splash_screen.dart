import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/storage_service.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/signin_screen.dart';
import '../main_navigation/main_bottom_nav.dart';

/// Design: a flat #FFE88B field with the wordmark centred (Splash (1).png).
/// The old build stretched the whole 393x852 Figma export edge to edge, which
/// cropped the mark on anything that was not an iPhone 15 Pro.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final isFirstTime = await StorageService.isFirstTime();
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();

    final Widget next = isFirstTime
        ? const OnboardingScreen()
        : authProvider.isAuthenticated
            ? const MainBottomNav()
            : const SignInScreen();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondary) => next,
        transitionsBuilder: (context, animation, secondary, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);

    return Scaffold(
      backgroundColor: AppColors.yellow,
      body: Center(
        // The mark lands, then breathes very slightly until we navigate away.
        // (A shimmer sweep was tried here and dropped: its ShaderMask ends the
        // sweep with an empty mask, which left the logo invisible.)
        child: const AppBrandLogo(width: 270)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 1, end: 1.035, duration: 1700.ms, curve: Curves.easeInOut)
            .animate()
            .fadeIn(duration: 700.ms, curve: Curves.easeOut)
            .scaleXY(begin: 0.86, end: 1, duration: 900.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
