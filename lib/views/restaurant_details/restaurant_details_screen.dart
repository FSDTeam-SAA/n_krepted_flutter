import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/open_external_link.dart';
import '../../core/widgets/discovery_widgets.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../core/widgets/photo_gallery.dart';
import '../../core/widgets/rating_badge.dart';
import '../../core/widgets/bottom_action_bar.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/feature_content.dart';
import '../../data/models/deal_model.dart';
import '../../providers/deal_provider.dart';
import '../dish_details/dish_details_screen.dart';
import '../booking_checkin/checkin_screen.dart';
import '../reviews/write_review_screen.dart';
import '../reviews/all_reviews_screen.dart';
import '../map_explore/explore_map_screen.dart';
import '../home/dessert_suggestion.dart';
import '../../core/constants/app_text_styles.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final DealModel deal;
  const RestaurantDetailsScreen({super.key, required this.deal});
  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  DealModel? _restaurant;
  String? _error;
  String _category = '';
  bool _loading = true;
  bool _viewRecorded = false;
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
    final result = await provider.getDealDetails(widget.deal.id);
    if (result != null && !_viewRecorded) {
      _viewRecorded = true;
      provider.dealRepository.recordView(result.id);
    }
    if (mounted) {
      setState(() {
        _restaurant = result;
        _loading = false;
        _error = result == null
            ? provider.errorMessage ?? 'Restaurant nicht verfügbar.'
            : null;
      });
    }
  }

  void _openDish(DealDish dish) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DishDetailsScreen(deal: _restaurant!, dish: dish),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final restaurant = _restaurant;
    final dishes = restaurant?.activeDishes ?? <DealDish>[];
    final signature = dishes
        .where((dish) => dish.isSignatureDish)
        .take(3)
        .toList();
    final categories = dishes
        .map((dish) => dish.category)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    final visible = dishes
        .where((dish) => _category.isEmpty || dish.category == _category)
        .toList();
    if (_loading || restaurant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Restaurantdetails')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : DataState(
                _error ?? 'Restaurant nicht verfügbar.',
                onRetry: _load,
              ),
      );
    }
    return Scaffold(
      bottomNavigationBar: BottomActionBar(
        child: OutlinedButton.icon(
          onPressed: restaurant.isUpcoming
              ? null
              : () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WriteReviewScreen(dealId: restaurant.id),
                    ),
                  );
                  if (changed == true && mounted) {
                    await _load();
                    if (context.mounted) await showDessertSuggestion(context);
                  }
                },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Schildern Sie Ihre Erfahrungen'),
        ),
      ),
      body: OwnerPageBackground(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: const Color(0xFF202020),
                foregroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text(
                  'Restaurantdetails',
                  style: TextStyle(
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      RemotePhoto(restaurant.firstImage),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: AppSpacing.pagePadding,
                sliver: SliverList.list(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.restaurantName,
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: AppFontSizes.headingSmall,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SaveButton(restaurant: restaurant),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AllReviewsScreen(dealId: restaurant.id),
                        ),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          RatingBadge(rating: restaurant.rating),
                          Text(
                            '${restaurant.reviewCount} Bewertungen',
                            style: const TextStyle(
                              fontSize: AppFontSizes.small,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    if (signature.isNotEmpty) ...[
                      const Text(
                        'Signature-Gerichte',
                        style: TextStyle(
                          fontSize: AppFontSizes.button,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...signature.map((dish) => _dishCard(restaurant, dish)),
                    ] else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Noch keine Signature-Gerichte vorhanden.'),
                      ),
                    if (restaurant.location.label.isNotEmpty ||
                        restaurant.location.address.isNotEmpty)
                      InkWell(
                        onTap: restaurant.location.hasCoordinates
                            ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExploreMapScreen(
                                    initialRestaurant: restaurant,
                                  ),
                                ),
                              )
                            : null,
                        child: _info(
                          Icons.location_on,
                          [
                            restaurant.location.address,
                            restaurant.location.label,
                          ].where((v) => v.isNotEmpty).join(', '),
                        ),
                      ),
                    DistanceLine(restaurant),
                    TextButton.icon(
                      onPressed: () => openExternalLink(
                        context,
                        googleMapsDirections(restaurant),
                      ),
                      icon: const Icon(Icons.directions_walk),
                      label: const Text('Route in Google Maps'),
                    ),
                    if (restaurant.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Über das Restaurant',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      FormattedText(restaurant.description),
                    ],
                    PromotionList(restaurant),
                    for (final offer in restaurant.offers)
                      _info(Icons.local_offer_outlined, offer),
                    if (restaurant.healthNotice.isNotEmpty ||
                        restaurant.safetyComment.isNotEmpty ||
                        restaurant.safetyDisclaimer.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Gesundheit & Sicherheit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (restaurant.healthNotice.isNotEmpty)
                        FormattedText(restaurant.healthNotice),
                      if (restaurant.safetyComment.isNotEmpty)
                        FormattedText(restaurant.safetyComment),
                      if (restaurant.safetyDisclaimer.isNotEmpty)
                        FormattedText(restaurant.safetyDisclaimer),
                    ],
                    if (restaurant.openingHours.isNotEmpty)
                      _info(Icons.access_time, restaurant.openingHours),
                    if (restaurant.contactEmail.isNotEmpty)
                      InkWell(
                        onTap: () => openExternalLink(
                          context,
                          Uri(
                            scheme: 'mailto',
                            path: restaurant.contactEmail,
                          ).toString(),
                        ),
                        child: _info(
                          Icons.email_outlined,
                          restaurant.contactEmail,
                        ),
                      ),
                    if (restaurant.contactPhone.isNotEmpty)
                      InkWell(
                        onTap: () => openExternalLink(
                          context,
                          Uri(
                            scheme: 'tel',
                            path: restaurant.contactPhone,
                          ).toString(),
                        ),
                        child: _info(
                          Icons.phone_outlined,
                          restaurant.contactPhone,
                        ),
                      ),
                    if (restaurant.reservationRequired != null)
                      _info(
                        Icons.check_box_outlined,
                        restaurant.reservationRequired!
                            ? 'Reservierung erforderlich'
                            : 'Keine Reservierung erforderlich',
                      ),
                    if (restaurant.isUpcoming)
                      _info(
                        Icons.schedule,
                        'Demnächst verfügbar: ${restaurant.opensAt!.toLocal()}',
                      ),
                    ..._restaurantPhotoSections(restaurant),
                    const SizedBox(height: 24),
                    if (!restaurant.isUpcoming && signature.isEmpty)
                      FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckinScreen(deal: restaurant),
                          ),
                        ),
                        icon: const Icon(Icons.my_location),
                        label: const Text('Einchecken'),
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      'Alle Gerichte',
                      style: TextStyle(
                        fontSize: AppFontSizes.button,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (categories.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Alle'),
                              selected: _category.isEmpty,
                              onSelected: (_) => setState(() => _category = ''),
                            ),
                            for (final category in categories)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: _category == category,
                                  onSelected: (_) =>
                                      setState(() => _category = category),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (visible.isEmpty)
                      const Text('Noch keine Gerichte vorhanden.')
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visible.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 14,
                            ),
                        itemBuilder: (_, index) {
                          final dish = visible[index];
                          return GestureDetector(
                            onTap: () => _openDish(dish),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  RemotePhoto(dish.image, fit: BoxFit.contain),
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: RatingBadge(rating: dish.rating),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black45,
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        dish.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: AppFontSizes.small,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _restaurantPhotoSections(DealModel restaurant) {
    const labels = {
      'interior': 'Innenbereich',
      'exterior': 'Außenbereich',
      'other': 'Weitere Restaurantbereiche',
    };
    final sections = <Widget>[];
    for (final entry in labels.entries) {
      final photos = <String>[
        for (var i = 0; i < restaurant.images.length; i++)
          if ((i < restaurant.photoCategories.length
                  ? restaurant.photoCategories[i]
                  : 'other') ==
              entry.key)
            restaurant.images[i],
      ];
      if (photos.isEmpty) continue;
      sections.addAll([
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Text(entry.value)),
            TextButton(
              onPressed: () => openPhotoGallery(context, photos),
              child: const Text('Alle anzeigen'),
            ),
          ],
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, index) => GestureDetector(
              onTap: () =>
                  openPhotoGallery(context, photos, initialIndex: index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 100, child: RemotePhoto(photos[index])),
              ),
            ),
          ),
        ),
      ]);
    }
    return sections;
  }

  Widget _info(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: AppFontSizes.small,
              color: AppColors.textGrey,
            ),
          ),
        ),
      ],
    ),
  );
  Widget _dishCard(DealModel restaurant, DealDish dish) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.item),
    child: Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDish(dish),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RemotePhoto(dish.image, fit: BoxFit.cover),
                  if (dish.isSignatureDish)
                    const Positioned(
                      left: 10,
                      top: 10,
                      child: SignatureBadge(),
                    ),
                  if (!restaurant.isUpcoming)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FilledButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckinScreen(deal: restaurant),
                          ),
                        ),
                        child: const Text('Einchecken'),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          style: const TextStyle(
                            fontSize: AppFontSizes.headingLarge,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SaveButton(restaurant: restaurant, dishId: dish.id),
                    ],
                  ),
                  if (dish.description.isNotEmpty)
                    Text(
                      plainDescription(dish.description),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppFontSizes.small,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 10),
                  FoodTags(dish.tags),
                  PromotionList(restaurant, dish: dish),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatEuro(context, dish.price),
                        style: const TextStyle(
                          fontSize: AppFontSizes.title,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RatingBadge(rating: dish.rating),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${dish.reviewCount} Bewertungen',
                              style: const TextStyle(
                                fontSize: AppFontSizes.captionSmall,
                              ),
                            ),
                          ),
                        ],
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
  );
}
