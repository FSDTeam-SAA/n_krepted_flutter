import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/review_model.dart';
import '../../providers/review_provider.dart';

class OwnerRatingsScreen extends StatelessWidget {
  final String restaurantId;

  const OwnerRatingsScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return _RatingsLoader(restaurantId: restaurantId);
  }
}

class _RatingsLoader extends StatefulWidget {
  final String restaurantId;

  const _RatingsLoader({required this.restaurantId});

  @override
  State<_RatingsLoader> createState() => _RatingsLoaderState();
}

class _RatingsLoaderState extends State<_RatingsLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReviewProvider>().fetchReviewsForDeal(
        widget.restaurantId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
    final reviews = provider.reviews;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Durchschnittliche Bewertungen',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned(
            right: -36,
            top: -40,
            child: _Decoration(asset: AppAssets.homeDecoHerbs, width: 110),
          ),
          const Positioned(
            right: -34,
            bottom: -10,
            child: _Decoration(asset: AppAssets.decoSkewers, width: 145),
          ),
          if (provider.isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  provider.fetchReviewsForDeal(widget.restaurantId),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  _DistributionCard(reviews: reviews),
                  const SizedBox(height: 16),
                  _TrendCard(reviews: reviews),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  final List<ReviewModel> reviews;

  const _DistributionCard({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final counts = List<int>.generate(
      5,
      (index) =>
          reviews.where((review) => review.ratings.round() == 5 - index).length,
    );
    final maxCount = counts.fold<int>(0, math.max);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: List.generate(5, (index) {
          final stars = 5 - index;
          final count = counts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 105,
                  child: Row(
                    children: List.generate(
                      5,
                      (star) => Icon(
                        star < stars ? Icons.star : Icons.star_border,
                        size: 18,
                        color: star < stars
                            ? AppColors.orangeAccent
                            : const Color(0xFFD9DADD),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: maxCount == 0 ? 0 : count / maxCount,
                      color: AppColors.orangeAccent,
                      backgroundColor: const Color(0xFFE4E5E7),
                    ),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    '$count',
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final List<ReviewModel> reviews;

  const _TrendCard({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final sorted = [...reviews]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final average = reviews.isEmpty
        ? 0.0
        : reviews.fold<double>(0, (sum, item) => sum + item.ratings) /
              reviews.length;
    final points = sorted.isEmpty
        ? const <double>[]
        : sorted.map((item) => item.ratings.clamp(0, 5).toDouble()).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konsistenz der Bewertung',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text(
            '30-Tage-Rezensenten-Trend',
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${average.toStringAsFixed(1).replaceAll('.', ',')} ★',
              style: const TextStyle(
                color: AppColors.orangeAccent,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 210,
            width: double.infinity,
            child: CustomPaint(painter: _RatingTrendPainter(points)),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('VOR 30 TAGEN', style: _axisStyle),
              Text('HEUTE', style: _axisStyle),
            ],
          ),
        ],
      ),
    );
  }
}

const _axisStyle = TextStyle(
  fontSize: 11,
  letterSpacing: .8,
  color: AppColors.textGrey,
  fontWeight: FontWeight.w600,
);

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white.withValues(alpha: .95),
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: AppColors.cardBorder),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: .06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);

class _RatingTrendPainter extends CustomPainter {
  final List<double> values;

  _RatingTrendPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFF0F1F2)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (values.isEmpty) return;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y = size.height - (values[i] / 5 * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF00B91D)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RatingTrendPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _Decoration extends StatelessWidget {
  final String asset;
  final double width;

  const _Decoration({required this.asset, required this.width});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Opacity(
      opacity: .25,
      child: Image.asset(asset, width: width, fit: BoxFit.contain),
    ),
  );
}
