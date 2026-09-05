import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/rating_badge.dart';
import '../../providers/saved_provider.dart';
import '../dish_details/dish_details_screen.dart';

class SavedDishesScreen extends StatelessWidget {
  const SavedDishesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedProvider = context.watch<SavedProvider>();
    final savedDeals = savedProvider.savedDeals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Gespeichert',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: savedProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : savedDeals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.favorite_border,
                    size: 56,
                    color: AppColors.textLightGrey,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Keine gespeicherten Gerichte vorhanden.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tippen Sie auf das Herz-Symbol, um Gerichte zu speichern.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textLightGrey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: savedDeals.length,
              itemBuilder: (context, index) {
                final deal = savedDeals[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DishDetailsScreen(deal: deal),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Dish Photo Stack
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(18),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: deal.firstImage,
                                width: 125,
                                height: 105,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (deal.sdRating > 0)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: RatingBadge(
                                  rating: deal.sdRating,
                                  isSdBadge: true,
                                ),
                              ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: RatingBadge(
                                rating: deal.rating,
                                isSdBadge: false,
                              ),
                            ),
                          ],
                        ),

                        // Content Details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        deal.restaurantName,
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          savedProvider.toggleSave(deal),
                                      child: const Icon(
                                        Icons.favorite,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: AppColors.badgeRed,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${deal.location.city}, ${deal.location.country}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${deal.distance}  •  ${deal.duration}',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                    if (deal.category?.categoryName
                                            .trim()
                                            .isNotEmpty ==
                                        true)
                                      Text(
                                        deal.category!.categoryName,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
