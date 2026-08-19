import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../data/models/deal_model.dart';
import '../../providers/saved_provider.dart';
import 'app_motion.dart';
import 'rating_badge.dart';

class DishCard extends StatelessWidget {
  final DealModel deal;
  final VoidCallback? onTap;
  final bool showBookmark;
  final double? width;

  const DishCard({
    super.key,
    required this.deal,
    this.onTap,
    this.showBookmark = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final savedProvider = context.watch<SavedProvider>();
    final isSaved = savedProvider.isSaved(deal.id);

    return Pressable(
      onTap: onTap,
      child: Container(
        width: width ?? 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Stack
            Stack(
              children: [
                Hero(
                  tag: 'dish-image-${deal.id}',
                  child: CachedNetworkImage(
                    imageUrl: deal.firstImage,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    ),
                  ),
                ),

                // Top-Left SD Badge
                const Positioned(
                  top: 8,
                  left: 8,
                  child: RatingBadge(rating: 4.5, isSdBadge: true),
                ),

                // Top-Right User Rating Badge
                const Positioned(
                  top: 8,
                  right: 8,
                  child: RatingBadge(rating: 4.5, isSdBadge: false),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          deal.dishName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${deal.price.toStringAsFixed(2).replaceAll('.', ',')} \$',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (showBookmark)
                        GestureDetector(
                          onTap: () => savedProvider.toggleSave(deal),
                          child: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? AppColors.primary : AppColors.textGrey,
                            size: 18,
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
    );
  }
}
