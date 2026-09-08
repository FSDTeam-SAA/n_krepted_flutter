import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/discovery_widgets.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../core/widgets/photo_gallery.dart';
import '../../core/widgets/rating_badge.dart';
import '../../core/widgets/review_card.dart';
import '../../data/models/deal_model.dart';
import '../../providers/deal_provider.dart';
import '../../providers/review_provider.dart';
import '../reviews/all_reviews_screen.dart';
import '../reviews/write_review_screen.dart';
import '../home/dessert_suggestion.dart';

class DishDetailsScreen extends StatefulWidget {
  final DealModel deal;
  final DealDish? dish;
  const DishDetailsScreen({super.key, required this.deal, this.dish});
  @override
  State<DishDetailsScreen> createState() => _DishDetailsScreenState();
}

class _DishDetailsScreenState extends State<DishDetailsScreen> {
  DealModel? _restaurant;
  bool _loading = true;
  String? _error;
  int _imageIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final provider = context.read<DealProvider>();
    final reviews = context.read<ReviewProvider>();
    final restaurant = await provider.getDealDetails(widget.deal.id);
    if (!mounted) return;
    setState(() {
      _restaurant = restaurant;
      _loading = false;
      _imageIndex = 0;
      if (restaurant == null) {
        _error = provider.errorMessage ?? 'Gericht nicht verfügbar.';
      }
    });
    if (restaurant != null) await reviews.fetchReviewsForDeal(restaurant.id);
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = _restaurant;
    final id = widget.dish?.id ?? widget.deal.featuredDish?.id;
    final dish = restaurant?.activeDishes
        .where((item) => item.id == id)
        .firstOrNull;
    final reviewProvider = context.watch<ReviewProvider>();
    final reviews = reviewProvider
        .reviewsForDeal(widget.deal.id)
        .where((r) => r.dishId == id)
        .toList();
    final images = dish == null
        ? <String>[]
        : dish.images.isNotEmpty
        ? dish.images
        : [if (dish.image.isNotEmpty) dish.image];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature Dish', style: TextStyle(fontSize: 18)),
      ),
      bottomNavigationBar: dish == null || restaurant == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                child: OutlinedButton.icon(
                  onPressed: restaurant.isUpcoming
                      ? null
                      : () async {
                          final changed = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WriteReviewScreen(
                                dealId: restaurant.id,
                                dishId: dish.id,
                              ),
                            ),
                          );
                          if (changed == true && mounted) {
                            await _load();
                            if (context.mounted) {
                              await showDessertSuggestion(context);
                            }
                          }
                        },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Schildern Sie Ihre Erfahrungen'),
                ),
              ),
            ),
      body: OwnerPageBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? DataState(_error!, onRetry: _load)
            : dish == null || restaurant == null
            ? const DataState('Dieses Gericht ist nicht mehr verfügbar.')
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    GestureDetector(
                      onTap: () => openPhotoGallery(
                        context,
                        images,
                        initialIndex: _imageIndex,
                      ),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: RemotePhoto(
                            fit: BoxFit.contain,
                            images.isEmpty ? '' : images[_imageIndex],
                          ),
                        ),
                      ),
                    ),
                    if (images.length > 1) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 106,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => setState(() => _imageIndex = i),
                            child: Container(
                              width: 106,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: i == _imageIndex
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: RemotePhoto(
                                images[i],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dish.name,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SaveButton(restaurant: restaurant, dishId: dish.id),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatEuro(context, dish.price),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        RatingBadge(rating: dish.rating),
                        const SizedBox(width: 5),
                        Text(
                          '${dish.reviewCount} Bewertungen',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    if (dish.description.trim().isNotEmpty)
                      _section('Beschreibung', dish.description),
                    if (dish.specialtyDescription.trim().isNotEmpty)
                      _section(
                        'Spezialität des Gerichts',
                        dish.specialtyDescription,
                      ),
                    if (dish.ingredients.isNotEmpty ||
                        dish.preparationProcess.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Zubereitungsmethode',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (dish.ingredients.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Hauptzutaten',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (_, constraints) => Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              for (final ingredient in dish.ingredients)
                                SizedBox(
                                  width: (constraints.maxWidth - 12) / 2,
                                  child: Text(
                                    '•  $ingredient',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      if (dish.preparationProcess.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Text(
                          'Herstellungsprozess',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(dish.preparationProcess, style: _bodyStyle),
                      ],
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Rezensionen',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AllReviewsScreen(
                                dealId: restaurant.id,
                                dishId: dish.id,
                              ),
                            ),
                          ),
                          child: const Text('Alle anzeigen'),
                        ),
                      ],
                    ),
                    if (reviewProvider.isLoadingFor(restaurant.id))
                      const LinearProgressIndicator()
                    else if (reviewProvider.errorFor(restaurant.id) != null)
                      DataState(
                        reviewProvider.errorFor(restaurant.id)!,
                        onRetry: () =>
                            reviewProvider.fetchReviewsForDeal(restaurant.id),
                      )
                    else if (reviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Noch keine Bewertungen vorhanden.',
                          style: _bodyStyle,
                        ),
                      )
                    else
                      ...reviews
                          .take(2)
                          .map((r) => ReviewCard(review: r, showVisit: false)),
                  ],
                ),
              ),
      ),
    );
  }

  static const _bodyStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textGrey,
    height: 1.5,
  );
  Widget _section(String title, String body) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Text(body, style: _bodyStyle),
      ],
    ),
  );
}
