import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/rating_badge.dart';
import '../../data/models/deal_model.dart';
import '../../providers/saved_provider.dart';
import '../dish_details/dish_details_screen.dart';
import '../booking_checkin/checkin_screen.dart';
import '../reviews/write_review_screen.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final DealModel deal;

  const RestaurantDetailsScreen({super.key, required this.deal});

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  String _selectedCategory = 'Deutsche Küche';

  final List<String> _categories = [
    'Deutsche Küche',
    'Burger',
    'Pizza',
    'Erfrischungsgetränke',
  ];

  final List<String> _diningPhotos = [
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1543007630-9710e4a00a20?w=600&auto=format&fit=crop&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;
    final savedProvider = context.watch<SavedProvider>();
    final isSaved = savedProvider.isSaved(deal.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero App Bar with Cover Photo
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textDark,
                      size: 20,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? AppColors.primary : AppColors.textDark,
                        size: 20,
                      ),
                    ),
                    onPressed: () => savedProvider.toggleSave(deal),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Restaurantdetails',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                  background: CachedNetworkImage(
                    imageUrl: deal.images.length > 1
                        ? deal.images[1]
                        : deal.firstImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Restaurant Info Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Cuisine Tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              deal.restaurantName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Text(
                            deal.category?.categoryName ?? 'Italian',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Location with red pin
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.badgeRed,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${deal.location.city}, ${deal.location.country}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Distance & Time
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_walk,
                            color: AppColors.textGrey,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${deal.distance}  •  ${deal.duration}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Operating hours
                      Row(
                        children: const [
                          Icon(
                            Icons.access_time,
                            color: AppColors.primary,
                            size: 15,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Montag bis Samstag (9 bis 20 Uhr)',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Contact & Phone
                      Row(
                        children: const [
                          Icon(Icons.call, color: AppColors.textGrey, size: 15),
                          SizedBox(width: 6),
                          Text(
                            '+49 151 23456789',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                          SizedBox(width: 14),
                          Icon(
                            Icons.email_outlined,
                            color: AppColors.textGrey,
                            size: 15,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'restaurantjan@gmail.com',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Physical check-in note
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Check-in vor Ort innerhalb von 100 m',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Bilder Der Location (Dining Gallery)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Bilder Der Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Alle anzeigen',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _diningPhotos.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    _diningPhotos[index],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (deal.dishes.any((dish) => dish.isSignatureDish)) ...[
                        ...deal.dishes
                            .where((dish) => dish.isSignatureDish)
                            .toList()
                            .asMap()
                            .entries
                            .expand(
                              (entry) => [
                                _buildSignatureDishBigCard(
                                  title: 'Signature Dish ${entry.key + 1}',
                                  dishName: entry.value.name,
                                  image: entry.value.image.isNotEmpty
                                      ? entry.value.image
                                      : deal.firstImage,
                                  description: entry.value.description,
                                  price: entry.value.price,
                                  dish: entry.value,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                      ] else ...[
                        _buildSignatureDishBigCard(
                          title: 'Signature Dish',
                          dishName: deal.dishName,
                          image: deal.firstImage,
                          description: deal.description,
                          price: deal.price,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Alle Gerichte Category Filter
                      const Text(
                        'Alle Gerichte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final isSel = _selectedCategory == cat;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFFFFF9E6)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSel
                                      ? Border.all(
                                          color: AppColors.orangeAccent,
                                        )
                                      : null,
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSel
                                        ? AppColors.textDark
                                        : AppColors.textGrey,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2-Column Dish Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                        children: deal.dishes.isNotEmpty
                            ? deal.dishes
                                  .map(
                                    (dish) => _buildGridDishItem(
                                      dish.name,
                                      dish.image.isNotEmpty
                                          ? dish.image
                                          : deal.firstImage,
                                    ),
                                  )
                                  .toList()
                            : [
                                _buildGridDishItem(
                                  'Schnitzel',
                                  deal.firstImage,
                                ),
                              ],
                      ),

                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Floating Button: Schildern Sie Ihre Erfahrungen
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WriteReviewScreen(dealId: deal.id),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Schildern Sie Ihre Erfahrungen',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureDishBigCard({
    required String title,
    required String dishName,
    required String image,
    required String description,
    required double price,
    DealDish? dish,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DishDetailsScreen(deal: widget.deal, dish: dish),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // Badges
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: RatingBadge(rating: 4.5, isSdBadge: true),
                    ),
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: RatingBadge(rating: 4.5, isSdBadge: false),
                    ),
                    // Einchecken Button Overlay
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckinScreen(deal: widget.deal),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Einchecken',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dishName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const Icon(
                            Icons.favorite_border,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${price.toStringAsFixed(2).replaceAll('.', ',')} \$',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const Text(
                            '12 Bewertungen',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridDishItem(String name, String image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: image,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const Positioned(
            top: 8,
            left: 8,
            child: RatingBadge(rating: 4.5, isSdBadge: true),
          ),
          const Positioned(
            top: 8,
            right: 8,
            child: RatingBadge(rating: 4.5, isSdBadge: false),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
