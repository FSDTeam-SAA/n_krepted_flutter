import 'package:flutter/material.dart';
import 'discovery_widgets.dart';

/// Photo pin with an attached tapered stem and ground shadow, as in the design.
class RestaurantMapPin extends StatelessWidget {
  final String imageUrl;
  final bool selected;
  const RestaurantMapPin({
    super.key,
    required this.imageUrl,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = selected ? 44.0 : 32.0;
    return Align(alignment: Alignment.bottomCenter, child: SizedBox(
      width: diameter + 8,
      height: diameter + 24,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: diameter * .7,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF35B654).withValues(alpha: .28),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            top: diameter - 6,
            child: CustomPaint(size: const Size(22, 27), painter: _PinStem()),
          ),
          Container(
            width: diameter,
            height: diameter,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFF147E32),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(child: RemotePhoto(imageUrl)),
            ),
          ),
        ],
      ),
    ));
  }
}

class _PinStem extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..quadraticBezierTo(
        size.width * .7,
        size.height * .65,
        size.width / 2,
        size.height,
      )
      ..quadraticBezierTo(size.width * .3, size.height * .65, 0, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF126A28), Color(0xFF1DDD3D)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _PinStem oldDelegate) => false;
}
