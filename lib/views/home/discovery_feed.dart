import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deal_provider.dart';
import '../../core/widgets/discovery_widgets.dart';
import '../../core/widgets/restaurant_card.dart';
import '../dish_details/dish_details_screen.dart';
import '../restaurant_details/restaurant_details_screen.dart';

class DiscoveryFeed extends StatelessWidget {
  final bool compact;
  const DiscoveryFeed({super.key, this.compact = false});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DealProvider>();
    if (provider.isLoading && provider.deals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.deals.isEmpty) {
      return DataState(provider.errorMessage!, onRetry: provider.fetchDeals);
    }
    if (provider.deals.isEmpty) {
      return DataState(
        provider.availability == 'upcoming'
            ? 'Aktuell sind keine Neueröffnungen angekündigt.'
            : 'Keine passenden Restaurants oder Gerichte gefunden.',
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 350 &&
            provider.errorMessage == null) {
          provider.fetchDeals(loadMore: true);
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: provider.fetchDeals,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          itemCount: provider.deals.length + 1,
          itemBuilder: (context, index) {
            if (index == provider.deals.length) {
              return provider.errorMessage != null
                  ? DataState(
                      provider.errorMessage!,
                      onRetry: () => provider.fetchDeals(loadMore: true),
                    )
                  : provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink();
            }
            final restaurant = provider.deals[index];
            final query = provider.searchQuery.toLowerCase();
            final matchedDish = query.isEmpty
                ? null
                : restaurant.activeDishes
                      .where((dish) => dish.name.toLowerCase().contains(query))
                      .firstOrNull;
            return RestaurantCard(
              deal: restaurant,
              dish: matchedDish,
              compact: compact,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantDetailsScreen(deal: restaurant),
                ),
              ),
              onDishTap: (dish) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DishDetailsScreen(deal: restaurant, dish: dish),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
