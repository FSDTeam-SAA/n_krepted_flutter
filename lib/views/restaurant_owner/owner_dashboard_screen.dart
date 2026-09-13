import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../data/models/deal_model.dart';
import '../../data/models/review_model.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/owner_restaurant_provider.dart';
import '../../providers/review_provider.dart';
import '../dish_details/dish_details_screen.dart';
import '../profile/profile_screen.dart';
import '../reviews/all_reviews_screen.dart';
import 'owner_workspace_screen.dart';
import 'owner_activity_screen.dart';
import 'owner_ratings_screen.dart';
import 'owner_dishes_screen.dart';
import '../../core/constants/app_text_styles.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  Future<void> _loadDashboard() async {
    final ownerProvider = context.read<OwnerRestaurantProvider>();
    await ownerProvider.refreshOwnerData();
    if (!mounted || ownerProvider.restaurant == null) return;
    await context.read<ReviewProvider>().fetchReviewsForDeal(
      ownerProvider.restaurant!.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageProvider>();
    final provider = context.watch<OwnerRestaurantProvider>();
    final reviews = context.watch<ReviewProvider>().reviews;
    final auth = context.watch<AuthProvider>();
    final restaurant = provider.restaurant;
    final dashboardDishes = restaurant == null
        ? const <DealDish>[]
        : _dashboardDishes(restaurant);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF8),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _DashboardHeader(
                avatarUrl: auth.currentUser?.avatar,
                onProfileTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
            ),
            if ((provider.isLoading || provider.isDashboardLoading) &&
                restaurant == null)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (restaurant == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _NoRestaurantDashboard(
                  message: language.text(
                    provider.errorMessage ??
                        'Erstellen Sie zuerst Ihr Restaurant.',
                    provider.errorMessage ??
                        'Create your restaurant before opening the dashboard.',
                  ),
                  onOpen: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerWorkspaceScreen(),
                    ),
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Positioned(
                        left: -70,
                        top: 50,
                        child: _DecorativeImage(
                          asset: AppAssets.homeDecoCoffee,
                          width: 138,
                          opacity: .13,
                          angle: -.18,
                        ),
                      ),
                      _StatsGrid(
                        language: language,
                        restaurant: restaurant,
                        provider: provider,
                        onReviewsTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AllReviewsScreen(dealId: restaurant.id),
                            ),
                          );
                        },
                        onRatingsTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OwnerRatingsScreen(restaurantId: restaurant.id),
                          ),
                        ),
                        onCheckInsTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerActivityScreen(
                              type: OwnerActivityType.checkIns,
                            ),
                          ),
                        ),
                        onViewersTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerActivityScreen(
                              type: OwnerActivityType.viewers,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        language.text('Signature-Gerichte', 'Signature Dishes'),
                        style: const TextStyle(
                          fontSize: AppFontSizes.button,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const OwnerDishesScreen(signaturesOnly: true),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(language.text('Verwalten', 'Manage')),
                      ),
                    ],
                  ),
                ),
              ),
              if (dashboardDishes.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _EmptyDishesCard(
                      text: language.text(
                        restaurant.dishes.isEmpty
                            ? 'Noch keine Gerichte vorhanden.'
                            : 'Noch kein Signature-Gericht vorhanden.',
                        restaurant.dishes.isEmpty
                            ? 'No dishes have been added yet.'
                            : 'No signature dish has been added yet.',
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerWorkspaceScreen(),
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList.separated(
                    itemCount: dashboardDishes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 22),
                    itemBuilder: (context, index) {
                      final dish = dashboardDishes[index];
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (index.isEven)
                            const Positioned(
                              right: -64,
                              top: 174,
                              child: _DecorativeImage(
                                asset: AppAssets.homeDecoOnion,
                                width: 112,
                                opacity: .20,
                                angle: -.24,
                              ),
                            )
                          else
                            const Positioned(
                              left: -66,
                              top: 210,
                              child: _DecorativeImage(
                                asset: AppAssets.homeDecoSpice,
                                width: 122,
                                opacity: .48,
                                angle: .12,
                              ),
                            ),
                          if (index == 0)
                            const Positioned(
                              left: -60,
                              bottom: -32,
                              child: _DecorativeImage(
                                asset: AppAssets.homeDecoSpice,
                                width: 116,
                                opacity: .42,
                                angle: .10,
                              ),
                            ),
                          _OwnerDishCard(
                            restaurant: restaurant,
                            dish: dish,
                            language: language,
                            review: _latestReviewForDish(reviews, dish),
                            onReviewsTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AllReviewsScreen(dealId: restaurant.id),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<DealDish> _dashboardDishes(DealModel restaurant) {
    final activeDishes = restaurant.dishes
        .where((dish) => dish.isActive)
        .toList();
    final signatureDishes = activeDishes
        .where((dish) => dish.isSignatureDish)
        .toList();

    // Older dishes and regular owner-created dishes may not carry the
    // signature flag. The dashboard should still show what this account has
    // created instead of incorrectly rendering the empty state.
    return signatureDishes.isNotEmpty ? signatureDishes : activeDishes;
  }

  ReviewModel? _latestReviewForDish(List<ReviewModel> reviews, DealDish dish) {
    for (final review in reviews) {
      if ((review.dishId != null && review.dishId == dish.id) ||
          review.dishName?.trim().toLowerCase() ==
              dish.name.trim().toLowerCase()) {
        return review;
      }
    }
    return null;
  }
}

class _DashboardHeader extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onProfileTap;

  const _DashboardHeader({required this.avatarUrl, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.fromLTRB(20, 28, 18, 8),
      decoration: const BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: -8,
            top: -25,
            child: _DecorativeImage(
              asset: AppAssets.homeDecoHerbs,
              width: 82,
              opacity: .36,
              angle: -.12,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: const AppBrandLogo(width: 82),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(24),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(avatarUrl!)
                    : null,
                child: avatarUrl == null || avatarUrl!.isEmpty
                    ? const Icon(Icons.person, color: AppColors.textGrey)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AppLanguageProvider language;
  final DealModel restaurant;
  final OwnerRestaurantProvider provider;
  final VoidCallback onReviewsTap;
  final VoidCallback onRatingsTap;
  final VoidCallback onCheckInsTap;
  final VoidCallback onViewersTap;

  const _StatsGrid({
    required this.language,
    required this.restaurant,
    required this.provider,
    required this.onReviewsTap,
    required this.onRatingsTap,
    required this.onCheckInsTap,
    required this.onViewersTap,
  });

  @override
  Widget build(BuildContext context) {
    final stats = provider.dashboardStats;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.58,
      children: [
        _StatCard(
          icon: Icons.star,
          iconColor: AppColors.orangeAccent,
          label: language.text('Durchschnittliche Bewertung', 'Average rating'),
          value: restaurant.rating.toStringAsFixed(1),
          onTap: onRatingsTap,
        ),
        _StatCard(
          icon: Icons.reviews,
          iconColor: const Color(0xFF4DB6AC),
          label: language.text('Bewertungen insgesamt', 'Total reviews'),
          value: _compactNumber(stats.totalReviews),
          onTap: onReviewsTap,
        ),
        _StatCard(
          icon: Icons.thumb_up_alt_outlined,
          iconColor: AppColors.primary,
          label: language.text('Check-ins insgesamt', 'Total check-ins'),
          value: _compactNumber(
            stats.totalCheckIns > 0
                ? stats.totalCheckIns
                : restaurant.totalCheckIns,
          ),
          onTap: onCheckInsTap,
        ),
        _StatCard(
          icon: Icons.visibility_outlined,
          iconColor: const Color(0xFF8B2CFF),
          label: language.text('Aufrufe insgesamt', 'Total viewers'),
          value: _compactNumber(stats.totalCustomers),
          onTap: onViewersTap,
        ),
      ],
    );
  }

  static String _compactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toString();
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF9E6),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 17, color: iconColor),
              const Spacer(),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppFontSizes.small,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                value,
                style: const TextStyle(
                  fontSize: AppFontSizes.titleSmall,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerDishCard extends StatelessWidget {
  final DealModel restaurant;
  final DealDish dish;
  final AppLanguageProvider language;
  final ReviewModel? review;
  final VoidCallback onReviewsTap;

  const _OwnerDishCard({
    required this.restaurant,
    required this.dish,
    required this.language,
    required this.review,
    required this.onReviewsTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = dish.image.isNotEmpty ? dish.image : restaurant.firstImage;
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DishDetailsScreen(deal: restaurant, dish: dish),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: Color(0xFFF8FAFC)),
                ),
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 264,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    height: 264,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.restaurant_menu, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 72,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restaurant_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          dish.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppFontSizes.small,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '${restaurant.rating.toStringAsFixed(1)} ★',
                      style: const TextStyle(
                        color: AppColors.orangeAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: AppFontSizes.small,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 16, 13, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        language.text('Rezensionen', 'Reviews'),
                        style: const TextStyle(
                          fontSize: AppFontSizes.body,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: onReviewsTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            language.text('Alle anzeigen', 'View all'),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: AppFontSizes.captionSmall,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  if (review == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        language.text(
                          'Noch keine Rezensionen für dieses Gericht.',
                          'No reviews for this dish yet.',
                        ),
                        style: const TextStyle(
                          fontSize: AppFontSizes.caption,
                          color: AppColors.textGrey,
                        ),
                      ),
                    )
                  else
                    _ReviewPreview(review: review!, language: language),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewPreview extends StatelessWidget {
  final ReviewModel review;
  final AppLanguageProvider language;

  const _ReviewPreview({required this.review, required this.language});

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now()
        .difference(review.createdAt)
        .inDays
        .clamp(0, 999);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFFF1F3F5),
              backgroundImage:
                  review.user.avatar != null && review.user.avatar!.isNotEmpty
                  ? CachedNetworkImageProvider(review.user.avatar!)
                  : null,
              child: review.user.avatar == null || review.user.avatar!.isEmpty
                  ? const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.textGrey,
                    )
                  : null,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppFontSizes.labelSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    language.text('vor $days Tagen', '$days days ago'),
                    style: const TextStyle(
                      fontSize: AppFontSizes.tiny,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (index) => Icon(
                  index < review.ratings.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 14,
                  color: AppColors.orangeAccent,
                ),
              ),
            ),
          ],
        ),
        if (review.reviewComment.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            review.reviewComment,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppFontSizes.caption,
              height: 1.4,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ],
    );
  }
}

class _DecorativeImage extends StatelessWidget {
  final String asset;
  final double width;
  final double opacity;
  final double angle;

  const _DecorativeImage({
    required this.asset,
    required this.width,
    required this.opacity,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: angle,
          child: Image.asset(asset, width: width, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _EmptyDishesCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _EmptyDishesCard({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(text),
      ),
    );
  }
}

class _NoRestaurantDashboard extends StatelessWidget {
  final String message;
  final VoidCallback onOpen;

  const _NoRestaurantDashboard({required this.message, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront, size: 54, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onOpen,
              child: const Text('Restaurantverwaltung öffnen'),
            ),
          ],
        ),
      ),
    );
  }
}
