import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/review_card.dart';
import '../../core/widgets/rating_badge.dart';
import '../../data/models/deal_model.dart';
import '../../providers/review_provider.dart';
import '../../providers/saved_provider.dart';
import '../booking_checkin/checkin_screen.dart';
import '../reviews/all_reviews_screen.dart';

class DishDetailsScreen extends StatefulWidget {
  final DealModel deal;
  final DealDish? dish;

  const DishDetailsScreen({super.key, required this.deal, this.dish});

  @override
  State<DishDetailsScreen> createState() => _DishDetailsScreenState();
}

class _DishDetailsScreenState extends State<DishDetailsScreen> {
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().fetchReviewsForDeal(widget.deal.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;
    final dish = widget.dish;
    final dishName = dish?.name ?? deal.dishName;
    final dishPrice = dish?.price ?? deal.price;
    final dishDescription = dish != null
        ? dish.description.trim()
        : deal.description.trim();
    final galleryImages = dish != null
        ? (dish.images.isNotEmpty
              ? dish.images
              : <String>[if (dish.image.trim().isNotEmpty) dish.image.trim()])
        : deal.images
              .map((image) => image.trim())
              .where((image) => image.isNotEmpty)
              .toList();
    final reviewProvider = context.watch<ReviewProvider>();
    final dishReviews = dish == null
        ? reviewProvider.reviews
        : reviewProvider.reviews.where((review) {
            if (review.dishId?.isNotEmpty == true) {
              return review.dishId == dish.id;
            }
            return review.dishName?.trim().toLowerCase() ==
                dish.name.trim().toLowerCase();
          }).toList();
    final averageRating = dishReviews.isEmpty
        ? 0.0
        : dishReviews.fold<double>(
                0,
                (total, review) => total + review.ratings,
              ) /
              dishReviews.length;
    final specialtyDescription = dish?.specialtyDescription.trim() ?? '';
    final ingredients = dish?.ingredients ?? deal.ingredients;
    final preparationProcess =
        dish?.preparationProcess.trim() ?? deal.preparationProcess.trim();
    final savedProvider = context.watch<SavedProvider>();
    final isSaved = savedProvider.isSaved(deal.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          dishName,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              color: isSaved ? AppColors.primary : AppColors.textDark,
            ),
            onPressed: () => savedProvider.toggleSave(deal),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Selected Image
                Hero(
                  tag: 'dish-image-${deal.id}',
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: galleryImages.isEmpty
                        ? Container(
                            color: const Color(0xFFF8FAFC),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 48,
                              color: AppColors.textGrey,
                            ),
                          )
                        : ColoredBox(
                            color: const Color(0xFFF8FAFC),
                            child: CachedNetworkImage(
                              imageUrl: galleryImages[_selectedImageIndex],
                              fit: BoxFit.contain,
                              errorWidget: (_, _, _) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 44,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

                if (galleryImages.length > 1) ...[
                  const SizedBox(height: 12),

                  // Only render a gallery when the API actually returned
                  // multiple images. A one-image dish needs no duplicate
                  // thumbnail below its hero image.
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(galleryImages.length, (index) {
                        final isSelected = _selectedImageIndex == index;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedImageIndex = index),
                          child: Container(
                            width: 72,
                            height: 72,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2.2,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: galleryImages[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Title & SD Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dishName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (dish?.isSignatureDish == true) ...[
                      const SizedBox(width: 10),
                      RatingBadge(rating: averageRating, isSdBadge: true),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Price & Reviews count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${dishPrice.toStringAsFixed(2).replaceAll('.', ',')} €',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.orangeAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          averageRating.toStringAsFixed(1).replaceAll('.', ','),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${dishReviews.length} Bewertungen',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (dishDescription.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Beschreibung',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dishDescription,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textBody,
                      height: 1.5,
                    ),
                  ),
                ],

                if (specialtyDescription.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Spezialität des Gerichts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    specialtyDescription,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textBody,
                      height: 1.5,
                    ),
                  ),
                ],

                if (ingredients.isNotEmpty ||
                    preparationProcess.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Zubereitungsmethode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (ingredients.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Hauptzutaten',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 26,
                          ),
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) => Row(
                        children: [
                          const Icon(
                            Icons.fiber_manual_record,
                            size: 8,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              ingredients[index],
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textBody,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (preparationProcess.isNotEmpty) ...[
                    if (ingredients.isNotEmpty) const SizedBox(height: 14),
                    Text(
                      preparationProcess,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textBody,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 24),

                // Rezensionen Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rezensionen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllReviewsScreen(dealId: deal.id),
                          ),
                        );
                      },
                      child: const Text(
                        'Alle anzeigen',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Reviews List
                if (dishReviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Noch keine Bewertungen vorhanden.',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  ...dishReviews.take(2).map((r) => ReviewCard(review: r)),

                const SizedBox(height: 90),
              ],
            ),
          ),

          // Bottom Action Bar: Einchecken Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: CustomButton(
              text: 'Einchecken',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CheckinScreen(deal: deal)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
