import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// One small motion vocabulary shared by every screen, so the whole app moves
/// with the same rhythm instead of each screen inventing its own timing.
///
/// The rule everywhere: short, soft, and never in the way of a tap.
class Motion {
  Motion._();

  static const Duration quick = Duration(milliseconds: 220);
  static const Duration base = Duration(milliseconds: 420);
  static const Duration slow = Duration(milliseconds: 700);
  static const Curve ease = Curves.easeOutCubic;

  /// Stagger step for lists and stacked form rows.
  static Duration step(int index, {int ms = 60, int max = 8}) =>
      Duration(milliseconds: (index.clamp(0, max)) * ms);
}

/// Wraps any tappable surface so it dips slightly under the finger. Cheap,
/// consistent tactile feedback for cards, chips and tiles.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.98,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && widget.onTap != null) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: Motion.quick,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

extension MotionX on Widget {
  /// Plain fade — for scattered garnish that should not travel.
  Widget fadeSoft({Duration? delay, Duration? duration}) => animate().fadeIn(
    delay: delay,
    duration: duration ?? Motion.slow,
    curve: Motion.ease,
  );

  /// Fade up — the default entrance for headings, copy and form rows.
  Widget fadeSlideUp({
    Duration? delay,
    double offset = 0.14,
    Duration? duration,
  }) => animate()
      .fadeIn(
        delay: delay,
        duration: duration ?? Motion.base,
        curve: Motion.ease,
      )
      .slideY(
        begin: offset,
        end: 0,
        delay: delay,
        duration: duration ?? Motion.base,
        curve: Motion.ease,
      );

  /// Fade in from the left/right, for artwork anchored to a screen edge.
  Widget fadeSlideX({
    Duration? delay,
    double offset = 0.18,
    Duration? duration,
  }) => animate()
      .fadeIn(
        delay: delay,
        duration: duration ?? Motion.slow,
        curve: Motion.ease,
      )
      .slideX(
        begin: offset,
        end: 0,
        delay: delay,
        duration: duration ?? Motion.slow,
        curve: Motion.ease,
      );

  /// Settle in with a gentle scale — cards, badges, the splash mark.
  Widget popIn({Duration? delay, double from = 0.92, Duration? duration}) =>
      animate()
          .fadeIn(
            delay: delay,
            duration: duration ?? Motion.base,
            curve: Motion.ease,
          )
          .scale(
            begin: Offset(from, from),
            end: const Offset(1, 1),
            delay: delay,
            duration: duration ?? Motion.base,
            curve: Curves.easeOutBack,
          );

  /// Slow, endless drift. Used on onboarding food art so the screens breathe.
  Widget drift({double dy = 6, int seconds = 4, Duration? delay}) =>
      animate(onPlay: (c) => c.repeat(reverse: true), delay: delay).moveY(
        begin: -dy / 2,
        end: dy / 2,
        duration: Duration(milliseconds: seconds * 1000),
        curve: Curves.easeInOut,
      );
}
