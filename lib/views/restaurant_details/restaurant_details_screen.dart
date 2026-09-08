import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/open_external_link.dart';
import '../../core/widgets/discovery_widgets.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../core/widgets/photo_gallery.dart';
import '../../core/widgets/rating_badge.dart';
import '../../data/models/deal_model.dart';
import '../../providers/deal_provider.dart';
import '../dish_details/dish_details_screen.dart';
import '../booking_checkin/checkin_screen.dart';
import '../reviews/write_review_screen.dart';
import '../reviews/all_reviews_screen.dart';
import '../map_explore/explore_map_screen.dart';
import '../home/dessert_suggestion.dart';

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
    final signature = dishes.where((dish) => dish.isSignatureDish).toList();
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
          child: OutlinedButton.icon(
            onPressed: restaurant.isUpcoming
                ? null
                : () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteReviewScreen(dealId: restaurant.id),
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
      ),
      body: OwnerPageBackground(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
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
                padding: const EdgeInsets.all(20),
                sliver: SliverList.list(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.restaurantName,
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 20,
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
                      child: Row(
                        children: [
                          RatingBadge(rating: restaurant.rating),
                          const SizedBox(width: 6),
                          Text(
                            '${restaurant.reviewCount} Bewertungen',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    if (restaurant.images.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(child: Text('Essbereich')),
                          TextButton(
                            onPressed: () =>
                                openPhotoGallery(context, restaurant.images),
                            child: const Text('Alle anzeigen'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: restaurant.images.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, index) => GestureDetector(
                            onTap: () => openPhotoGallery(
                              context,
                              restaurant.images,
                              initialIndex: index,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 100,
                                child: RemotePhoto(restaurant.images[index]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (signature.isNotEmpty) ...[
                      const Text(
                        'Signature Dish',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...signature.map((dish) => _dishCard(restaurant, dish)),
                    ] else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Noch keine Signature Dishes vorhanden.'),
                      ),
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
                        fontSize: 15,
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
                                          fontSize: 12,
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
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ),
      ],
    ),
  );
  Widget _dishCard(DealModel restaurant, DealDish dish) => Padding(
    padding: const EdgeInsets.only(bottom: 30),
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
                  RemotePhoto(dish.image, fit: BoxFit.contain),
                  if (!restaurant.isUpcoming)
                    Positioned(
                      right: 0,
                      bottom: 36,
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SaveButton(restaurant: restaurant, dishId: dish.id),
                    ],
                  ),
                  if (dish.description.isNotEmpty)
                    Text(
                      dish.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 10),
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
                      const SizedBox(width: 4),
                      Text(
                        '${dish.reviewCount} Bewertungen',
                        style: const TextStyle(fontSize: 11),
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
