import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

class OwnerPageBackground extends StatelessWidget {
  final Widget child;

  const OwnerPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        right: -26,
        top: -58,
        child: _asset(AppAssets.homeDecoHerbs, 122, .3),
      ),
      Positioned(
        left: -54,
        top: 105,
        child: _asset(AppAssets.homeDecoCoffee, 116, .12),
      ),
      Positioned(
        left: -35,
        bottom: -26,
        child: _asset(AppAssets.homeDecoSpice, 116, .3),
      ),
      Positioned(
        right: -25,
        bottom: -22,
        child: _asset(AppAssets.decoSkewers, 145, .33),
      ),
      child,
    ],
  );

  Widget _asset(String path, double width, double opacity) => IgnorePointer(
    child: Opacity(
      opacity: opacity,
      child: Image.asset(path, width: width, fit: BoxFit.contain),
    ),
  );
}
