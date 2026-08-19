import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/storage_service.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/frame_positioned.dart';
import 'location_permission_screen.dart';

/// Rebuilt against the three Figma frames — `Splash (4).png`, `Onboarding 7.png`
/// and `Onboarding 8.png`. Every coordinate below is a measurement off those
/// 393 x 852 exports.
///
/// Shared furniture (top wave, skip, dots, cyan action blob) lives outside the
/// PageView so it stays put while the slides move; the food art rides a parallax
/// so the pages feel like layers rather than flat cards.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  /// Continuous page offset (0.0 -> 2.0), used for the parallax and the wave swap.
  double _page = 0;
  int get _index => _page.round();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final p = _pageController.hasClients ? (_pageController.page ?? 0) : 0.0;
      if (p != _page) setState(() => _page = p);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_index < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    await StorageService.setFirstTimeCompleted();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondary) => const LocationPermissionScreen(),
        transitionsBuilder: (context, animation, secondary, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);
    final isLast = _index == 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- top-left / top-right yellow wave -------------------------------
          // Slides 1 and 2 share one artwork: slide 1 pins it to the left,
          // slide 2 mirrors it against the right edge. Slide 3 swaps in the leaf.
          Positioned.fill(child: _TopDecoration(page: _page)),

          // ---- slides ---------------------------------------------------------
          PageView.builder(
            controller: _pageController,
            itemCount: 3,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, i) => _Slide(index: i, page: _page),
          ),

          // ---- skip -----------------------------------------------------------
          Positioned(
            top: AppSizes.topInset + 8.h,
            right: 12.w,
            child: TextButton(
              onPressed: _complete,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Überspringen',
                style: AppTextStyles.body(size: 14, color: AppColors.textMuted),
              ),
            ).fadeSlideUp(delay: const Duration(milliseconds: 250), offset: -0.3),
          ),

          // ---- page dots: 8px tall, first dot at x=20, baseline y=809 ---------
          FramePositioned(
            left: 20,
            bottom: 852 - 817,
            child: Row(
              children: List.generate(3, (i) {
                final active = _index == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(right: i == 2 ? 0 : 4.w),
                  width: (active ? 24 : 8).w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.dotInactive,
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                );
              }),
            ),
          ),

          // ---- cyan action blob: 134 x 219 at (259, 635), overhanging the
          // frame's bottom edge by 2 -------------------------------------------
          FramePositioned(
            right: 0,
            bottom: -AppAssets.blobCyanOverhang,
            width: AppAssets.blobCyanW,
            height: AppAssets.blobCyanH,
            child: GestureDetector(
              onTap: _onNext,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppAssets.blobCyan,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                  ),
                  // Slides 1-2: a bare 27px arrow at frame x 322..348, y 732.
                  // Last slide: the arrow slides right to x 357..377 and
                  // "Begonnen" fades in beside it at x 281.
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    right: (isLast ? 393 - 377 : 393 - 348).w,
                    top: (isLast ? 733 - 635 : 730 - 635).h,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      scale: isLast ? 22 / 27 : 1,
                      child: Icon(Icons.arrow_forward, color: Colors.white, size: 27.w),
                    ),
                  ),
                  Positioned(
                    left: (281 - 259).w,
                    top: (734 - 635).h,
                    child: AnimatedOpacity(
                      opacity: isLast ? 1 : 0,
                      duration: const Duration(milliseconds: 260),
                      child: Text(
                        'Begonnen',
                        style: AppTextStyles.label(
                          size: 16,
                          color: Colors.white,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).popIn(delay: const Duration(milliseconds: 300), from: 0.85),
          ),
        ],
      ),
    );
  }
}

/// Top-corner artwork. Cross-fades between the mirrored wave and the leaf blob
/// as the user swipes onto slide 3.
class _TopDecoration extends StatelessWidget {
  final double page;
  const _TopDecoration({required this.page});

  @override
  Widget build(BuildContext context) {
    // 0 -> left wave, 1 -> mirrored right wave, 2 -> leaf.
    final toRight = page.clamp(0.0, 1.0);
    final toLeaf = (page - 1).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Slide 1: wave at (0, 0). Slide 2: same wave mirrored against the right
        // edge. Sliding it across reads as one shape travelling with the pages.
        Opacity(
          opacity: 1 - toLeaf,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (toRight < 1)
                FramePositioned.art(
                  AppAssets.waveTop,
                  left: 0,
                  top: 0,
                  width: AppAssets.waveW,
                  height: AppAssets.waveH,
                  opacity: 1 - toRight,
                ),
              if (toRight > 0)
                FramePositioned.art(
                  AppAssets.waveTop,
                  right: 0,
                  top: 0,
                  width: AppAssets.waveW,
                  height: AppAssets.waveH,
                  mirrored: true,
                  opacity: toRight,
                ),
            ],
          ),
        ),
        // Slide 3: rounded leaf, 143 x 241 at (0, 2).
        if (toLeaf > 0)
          FramePositioned.art(
            AppAssets.blobLeaf,
            left: 0,
            top: 2,
            width: AppAssets.blobLeafW,
            height: AppAssets.blobLeafH,
            opacity: toLeaf,
          ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.15, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}

class _SlideCopy {
  final String title;
  final String body;
  final bool alignRight;
  const _SlideCopy(this.title, this.body, {this.alignRight = false});
}

/// Line breaks are baked in so the copy wraps exactly the way the design does.
const List<_SlideCopy> _copy = [
  _SlideCopy(
    'Entdecken Sie unsere\nSpezialitäten',
    'Entdecken Sie die außergewöhnlichsten und\nunvergesslichsten Gerichte aus den besten\nRestaurants und Bars in Ihrer Umgebung.',
  ),
  _SlideCopy(
    'Finde Gerichte, für die\nsich eine Reise lohnt',
    'Suchen Sie nach Stadt, Entfernung,\nBewertungen und angesagten Orten, um\nLokale zu entdecken, die von Feinschmeckern\nwirklich geliebt werden.',
    alignRight: true,
  ),
  _SlideCopy(
    'Vertrauenswürdige Bewertungen\nund echte Erfahrungen',
    'Lesen Sie vor Ihrer Bestellung detaillierte\nKundenbewertungen und exklusive Empfehlungen\ndes Signature Dish Teams.',
  ),
];

class _Slide extends StatelessWidget {
  final int index;
  final double page;
  const _Slide({required this.index, required this.page});

  /// How far this slide is from being the active one, -1..1.
  double get _delta => (page - index).clamp(-1.0, 1.0);

  /// Artwork drifts against the swipe direction to build depth.
  double _parallax(double strength) => -_delta * strength;

  @override
  Widget build(BuildContext context) {
    final copy = _copy[index];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ..._art(),

        // ---- title ---------------------------------------------------------
        // s1 y=300, s2 y=369 (right aligned), s3 y=340 — all at a 20px margin.
        FramePositioned(
          left: 20,
          right: 20,
          // +4 over the ink position measured off the frame, to allow for the
          // leading Kaushan puts above its cap line.
          top: index == 0
              ? 300
              : index == 1
                  ? 366
                  : 338,
          child: Transform.translate(
            offset: Offset(_parallax(28.w), 0),
            child: Text(
              copy.title,
              textAlign: copy.alignRight ? TextAlign.right : TextAlign.left,
              style: AppTextStyles.script(),
            ).fadeSlideUp(delay: const Duration(milliseconds: 120)),
          ),
        ),

        // ---- body ----------------------------------------------------------
        // 14px over a 21px line; s1 y=398, s2 y=467, s3 y=438.
        FramePositioned(
          left: 20,
          right: 20,
          top: index == 0
              ? 398
              : index == 1
                  ? 467
                  : 438,
          child: Transform.translate(
            offset: Offset(_parallax(18.w), 0),
            child: Text(
              copy.body,
              textAlign: copy.alignRight ? TextAlign.right : TextAlign.left,
              style: AppTextStyles.body(size: 13.5, color: AppColors.textMuted, height: 1.556),
            ).fadeSlideUp(delay: const Duration(milliseconds: 220)),
          ),
        ),
      ],
    );
  }

  /// One food cut-out at its measured frame rect. The entrance, the endless
  /// drift and the swipe parallax all go *inside* the `Positioned`, because
  /// wrapping the `Positioned` itself would strip its coordinates.
  Widget _art1(
    String asset, {
    required double left,
    required double top,
    required double width,
    required double height,
    required double parallax,
    double dy = 6,
    int seconds = 5,
    double from = 0,
  }) {
    Widget child = Image.asset(asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium)
        .drift(dy: dy, seconds: seconds);

    child = from == 0
        ? child.fadeSoft(delay: const Duration(milliseconds: 350))
        : child.fadeSlideX(offset: from);

    return FramePositioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: IgnorePointer(
        child: Transform.translate(
          offset: Offset(_parallax(parallax), 0),
          child: child,
        ),
      ),
    );
  }

  List<Widget> _art() {
    switch (index) {
      case 0:
        return [
          _art1(AppAssets.onb1Coffee,
              left: 193, top: 114, width: 200, height: 233, parallax: 64.w, dy: 7, from: 0.25),
          _art1(AppAssets.onb1Beef,
              left: 0, top: 503, width: 185, height: 276, parallax: 46.w, seconds: 6, from: -0.25),
          _art1(AppAssets.onb1Spice,
              left: 280, top: 486, width: 113, height: 109, parallax: 88.w, dy: 5, seconds: 4),
        ];
      case 1:
        return [
          _art1(AppAssets.onb2Pan,
              left: 0, top: 108, width: 211, height: 276, parallax: 64.w, dy: 7, from: -0.25),
          _art1(AppAssets.onb2Skewers,
              left: 0, top: 554, width: 193, height: 221, parallax: 46.w, seconds: 6, from: -0.25),
        ];
      default:
        return [
          _art1(AppAssets.onb3Shake,
              left: 238, top: 77, width: 155, height: 271, parallax: 64.w, dy: 7, from: 0.25),
          _art1(AppAssets.onb3Pancakes,
              left: 0, top: 550, width: 190, height: 219, parallax: 46.w, seconds: 6, from: -0.25),
          _art1(AppAssets.onb3Garnish,
              left: 298, top: 498, width: 95, height: 100, parallax: 88.w, dy: 5, seconds: 4),
        ];
    }
  }
}
