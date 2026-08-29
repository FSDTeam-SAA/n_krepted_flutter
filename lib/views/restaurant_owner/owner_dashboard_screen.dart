import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../data/models/deal_model.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/owner_restaurant_provider.dart';
import '../dish_details/dish_details_screen.dart';
import '../profile/profile_screen.dart';
import '../reviews/all_reviews_screen.dart';
import 'owner_workspace_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerRestaurantProvider>().refreshOwnerData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageProvider>();
    final provider = context.watch<OwnerRestaurantProvider>();
    final auth = context.watch<AuthProvider>();
    final restaurant = provider.restaurant;

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
                onManageTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OwnerWorkspaceScreen(),
                  ),
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
                  child: _StatsGrid(
                    language: language,
                    restaurant: restaurant,
                    provider: provider,
                    onReviewsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllReviewsScreen(
                            dealId: restaurant.id,
                          ),
                        ),
                      );
                    },
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
                        language.text('Signature Dish', 'Signature Dishes'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerWorkspaceScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(language.text('Verwalten', 'Manage')),
                      ),
                    ],
                  ),
                ),
              ),
              if (restaurant.dishes.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _EmptyDishesCard(
                      text: language.text(
                        'Noch keine Gerichte vorhanden.',
                        'No dishes have been added yet.',
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
                    itemCount: _dashboardDishes(restaurant).length,
                    separatorBuilder: (_, _) => const SizedBox(height: 22),
                    itemBuilder: (context, index) {
                      final dish = _dashboardDishes(restaurant)[index];
                      return _OwnerDishCard(
                        restaurant: restaurant,
                        dish: dish,
                        language: language,
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
    final signature = restaurant.dishes
        .where((dish) => dish.isSignatureDish)
        .toList();
    return signature.isNotEmpty ? signature : restaurant.dishes;
  }
}

class _DashboardHeader extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onProfileTap;
  final VoidCallback onManageTap;

  const _DashboardHeader({
    required this.avatarUrl,
    required this.onProfileTap,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.fromLTRB(20, 28, 18, 8),
      decoration: const BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const AppBrandLogo(width: 82),
          const Spacer(),
          IconButton(
            tooltip: 'Restaurant verwalten',
            onPressed: onManageTap,
            icon: const Icon(Icons.storefront_outlined),
            color: AppColors.primary,
          ),
          InkWell(
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

  const _StatsGrid({
    required this.language,
    required this.restaurant,
    required this.provider,
    required this.onReviewsTap,
  });

  @override
  Widget build(BuildContext context) {
    final stats = provider.dashboardStats;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.42,
      children: [
        _StatCard(
          icon: Icons.star,
          iconColor: AppColors.orangeAccent,
          label: language.text(
            'Durchschnittliche Bewertung',
            'Average rating',
          ),
          value: restaurant.rating.toStringAsFixed(1),
          onTap: onReviewsTap,
        ),
        _StatCard(
          icon: Icons.reviews,
          iconColor: const Color(0xFF4DB6AC),
          label: language.text('Gesamtbewertungen', 'Total reviews'),
          value: _compactNumber(stats.totalReviews),
          onTap: onReviewsTap,
        ),
        _StatCard(
          icon: Icons.thumb_up_alt_outlined,
          iconColor: AppColors.primary,
          label: language.text('Gesamteinchecken', 'Total check-ins'),
          value: _compactNumber(
            stats.totalCheckIns > 0
                ? stats.totalCheckIns
                : restaurant.totalCheckIns,
          ),
        ),
        _StatCard(
          icon: Icons.visibility_outlined,
          iconColor: const Color(0xFF8B2CFF),
          label: language.text('Gesamtzuschauer', 'Total viewers'),
          value: _compactNumber(stats.totalCustomers),
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
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 7),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
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

  const _OwnerDishCard({
    required this.restaurant,
    required this.dish,
    required this.language,
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
                    child: Text(
                      dish.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (dish.description.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      dish.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '${dish.price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${restaurant.reviewCount} ${language.text('Bewertungen', 'reviews')}',
                        style: const TextStyle(fontSize: 11.5),
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

  const _NoRestaurantDashboard({
    required this.message,
    required this.onOpen,
  });

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
