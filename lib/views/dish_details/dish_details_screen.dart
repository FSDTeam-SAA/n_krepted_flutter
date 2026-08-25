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

  final List<String> _galleryImages = [
    'https://images.unsplash.com/photo-1599921841143-819065a55cc6?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&auto=format&fit=crop&q=80',
  ];

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
    final dishDescription = dish?.description.isNotEmpty == true
        ? dish!.description
        : deal.description;
    final galleryImages = [
      if (dish?.image.isNotEmpty == true) dish!.image,
      ..._galleryImages,
    ];
    final reviewProvider = context.watch<ReviewProvider>();
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
                    child: CachedNetworkImage(
                      imageUrl: galleryImages[_selectedImageIndex],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Thumbnails Gallery Row
                Row(
                  children: List.generate(galleryImages.length, (index) {
                    final isSelected = _selectedImageIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedImageIndex = index),
                      child: Container(
                        width: 72,
                        height: 72,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2.2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl: galleryImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Title & SD Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dishName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const RatingBadge(rating: 4.5, isSdBadge: true),
                  ],
                ),

                const SizedBox(height: 8),

                // Price & Reviews count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${dishPrice.toStringAsFixed(2).replaceAll('.', ',')} \$',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.star, color: AppColors.orangeAccent, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4,5',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '12 Bewertungen',
                          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Beschreibung (Description)
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

                const SizedBox(height: 20),

                // Spezialität des Schnitzels
                const Text(
                  'Spezialität des Gerichts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Schnitzel ist berühmt für seine perfekt ausbalancierte Kombination aus knuspriger, goldbrauner Panade und zartem, saftigem Fleisch. Nach traditionellen Methoden zubereitet und mit frischer Zitrone serviert, bietet es ein volles Geschmackserlebnis.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textBody,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Zubereitungsmethode
                const Text(
                  'Zubereitungsmethode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),

                // Hauptzutaten (Main Ingredients 2-Col Grid)
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 26,
                  ),
                  itemCount: deal.ingredients.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        const Icon(Icons.fiber_manual_record, size: 8, color: AppColors.textGrey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            deal.ingredients[index],
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textBody),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 14),

                // Herstellungsprozess
                const Text(
                  'Herstellungsprozess',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  deal.preparationProcess,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textBody,
                    height: 1.5,
                  ),
                ),

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
                if (reviewProvider.reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Noch keine Bewertungen vorhanden.',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ...reviewProvider.reviews.take(2).map((r) => ReviewCard(review: r)),

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
                  MaterialPageRoute(
                    builder: (_) => CheckinScreen(deal: deal),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
