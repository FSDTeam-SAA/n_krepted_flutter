import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart'
    show AppleLogoPainter;

/// Google's unmodified multicolor G, bundled from its official branding assets.
class GoogleBrandIcon extends StatelessWidget {
  const GoogleBrandIcon({super.key});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/img/google_g.png',
    width: 20,
    height: 20,
    fit: BoxFit.contain,
    semanticLabel: 'Google',
  );
}

/// Reuses the Apple sign-in package's logo, independent of the app's teal theme.
class AppleBrandIcon extends StatelessWidget {
  const AppleBrandIcon({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Apple',
    image: true,
    child: const SizedBox(
      width: 18,
      height: 22,
      child: CustomPaint(painter: AppleLogoPainter(color: Colors.black)),
    ),
  );
}
