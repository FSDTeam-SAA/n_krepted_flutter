import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../data/models/deal_model.dart';
import '../../providers/saved_provider.dart';
import 'app_motion.dart';

class RestaurantCard extends StatelessWidget {
  final DealModel deal;
  final VoidCallback? onTap;
  final Function(DealModel)? onDishTap;

  const RestaurantCard({
    super.key,
    required this.deal,
    this.onTap,
    this.onDishTap,
  });

  @override
  Widget build(BuildContext context) {
    final savedProvider = context.watch<SavedProvider>();
    final isSaved = savedProvider.isSaved(deal.id);

    return Pressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Restaurant Dining Image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: deal.firstImage,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(height: 170, color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(
                    height: 170,
                    color: Colors.grey[200],
                    child: const Icon(Icons.store, color: Colors.grey),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Heart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          deal.restaurantName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => savedProvider.toggleSave(deal),
                        child: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved
                              ? AppColors.primary
                              : AppColors.textGrey,
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.badgeRed,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${deal.location.city}, ${deal.location.country}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Distance, Time & Cuisine Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_walk,
                            color: AppColors.textGrey,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${deal.distance}  •  ${deal.duration}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                      if (deal.category?.categoryName.trim().isNotEmpty == true)
                        Text(
                          deal.category!.categoryName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Signature Dishes 1, 2, 3 Preview Row matching design
                  if (deal.dishes.any((dish) => dish.isSignatureDish))
                    Row(
                      children: deal.dishes
                          .where((dish) => dish.isSignatureDish)
                          .take(3)
                          .toList()
                          .asMap()
                          .entries
                          .expand<Widget>(
                            (entry) => [
                              if (entry.key > 0) const SizedBox(width: 10),
                              _buildSignatureDishPreview(
                                label: 'Signature Dish ${entry.key + 1}',
                                image: entry.value.image,
                                title: entry.value.name,
                                onTap: () => onDishTap?.call(deal),
                              ),
                            ],
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureDishPreview({
    required String label,
    required String image,
    required String title,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: image,
                    height: 64,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.restaurant_menu,
                              color: AppColors.primary,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              '4,5 ★',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.orangeAccent,
                              ),
                            ),
                            Text(
                              'SD 4,5 ★',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.badgeRed,
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
          ],
        ),
      ),
    );
  }
}
