import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../data/models/deal_model.dart';
import '../../providers/deal_provider.dart';
import '../restaurant_details/restaurant_details_screen.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  int _selectedFilterTab = 0;
  String _selectedCategory = 'Deutsch';
  DealModel? _selectedDeal;

  final List<String> _categories = [
    'Deutsch',
    'Italienisch',
    'Indisch',
    'Chinesisch',
    'Japanisch',
  ];

  @override
  Widget build(BuildContext context) {
    final dealProvider = context.watch<DealProvider>();
    final deals = dealProvider.deals;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Simulated Interactive Map
          Positioned.fill(
            child: Image.asset(
              AppAssets.mapPlaceholder,
              fit: BoxFit.cover,
            ),
          ),

          // Custom Food Markers Positioned across Map
          if (deals.isNotEmpty) ...[
            _buildMapMarker(top: 240, left: 160, deal: deals[0]),
            if (deals.length > 1) _buildMapMarker(top: 310, right: 80, deal: deals[1]),
            if (deals.length > 2) _buildMapMarker(top: 420, left: 90, deal: deals[2]),
            if (deals.length > 3) _buildMapMarker(top: 480, right: 120, deal: deals[3]),
            if (deals.length > 4) _buildMapMarker(top: 590, left: 60, deal: deals[4]),
            if (deals.length > 5) _buildMapMarker(top: 660, left: 130, deal: deals[5]),
          ],

          // Top Header & Controls Stack
          SafeArea(
            child: Column(
              children: [
                // Top Header Card
                Container(
                  color: AppColors.background.withValues(alpha: 0.95),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppBrandLogo(width: 78),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.my_location, color: AppColors.textDark, size: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Tabs: Am besten bewertet / Am günstigsten / Am teuersten
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTabItem(0, 'Am besten bewertet'),
                          _buildTabItem(1, 'Am günstigsten'),
                          _buildTabItem(2, 'Am teuersten'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Horizontal Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _categories.map((cat) {
                      final isSel = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFF9E6) : Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(16),
                            border: isSel ? Border.all(color: AppColors.orangeAccent) : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? AppColors.textDark : AppColors.textBody,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Popup Card when marker is tapped
          if (_selectedDeal != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildPlacePreviewCard(_selectedDeal!),
            ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSel = _selectedFilterTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterTab = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
              color: isSel ? AppColors.textDark : AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2.5,
            width: 48,
            color: isSel ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required DealModel deal,
  }) {
    final isSelected = _selectedDeal?.id == deal.id;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: () => setState(() => _selectedDeal = deal),
        child: AnimatedScale(
          scale: isSelected ? 1.25 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: deal.firstImage,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(12, 8),
                painter: _PinTrianglePainter(color: const Color(0xFF22C55E)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlacePreviewCard(DealModel deal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: deal.firstImage,
              width: 74,
              height: 74,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  deal.restaurantName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${deal.location.city}, ${deal.location.country}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.orangeAccent, size: 14),
                    const SizedBox(width: 3),
                    const Text('4.8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(
                      '${deal.price.toStringAsFixed(2)} \$',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantDetailsScreen(deal: deal),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PinTrianglePainter extends CustomPainter {
  final Color color;
  _PinTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
