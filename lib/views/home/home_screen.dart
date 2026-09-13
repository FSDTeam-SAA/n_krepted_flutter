import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/curved_header.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../providers/deal_provider.dart';
import '../../providers/location_provider.dart';
import '../map_explore/explore_map_screen.dart';
import 'search_screen.dart';
import 'filter_modal.dart';
import 'categories_screen.dart';
import 'discovery_feed.dart';
import '../../core/constants/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DealProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: OwnerPageBackground(
        child: Column(
          children: [
            CurvedHeader(
              onLocationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExploreMapScreen()),
              ),
              bottomChild: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Material(
                      color: Colors.white,
                      elevation: 1,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 17,
                                color: AppColors.textGrey,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Finde Gerichte, Restaurants und Bars',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.small,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () => showDiscoveryFilters(context),
                          icon: const Icon(Icons.tune, size: 16),
                          label: const Text('Filter'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Demnächst verfügbar'),
                          selected: provider.availability == 'upcoming',
                          onSelected: (_) {
                            provider.availability =
                                provider.availability == 'upcoming'
                                ? 'active'
                                : 'upcoming';
                            provider.fetchDeals();
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Am besten bewertet'),
                          selected:
                              provider.availability == 'active' &&
                              provider.sort == 'rating',
                          onSelected: (_) {
                            provider.availability = 'active';
                            provider.sort = 'rating';
                            provider.fetchDeals();
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('In der Nähe'),
                          onPressed: () async {
                            final location = context.read<LocationProvider>();
                            if (await location.locate()) {
                              provider.availability = 'active';
                              provider.sort = 'nearest';
                              await provider.fetchDeals(
                                latitude: location.position!.latitude,
                                longitude: location.position!.longitude,
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    location.errorMessage ??
                                        'Standort nicht verfügbar.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('Kategorien'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CategoriesScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: DiscoveryFeed()),
          ],
        ),
      ),
    );
  }
}
