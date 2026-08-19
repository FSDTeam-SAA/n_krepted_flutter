import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/curved_header.dart';
import '../../core/widgets/restaurant_card.dart';
import '../../providers/deal_provider.dart';
import '../../providers/category_provider.dart';
import '../restaurant_details/restaurant_details_screen.dart';
import '../dish_details/dish_details_screen.dart';
import 'search_screen.dart';
import 'filter_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilterPill = 0;

  @override
  Widget build(BuildContext context) {
    final dealProvider = context.watch<DealProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top Curved Signature Header
          CurvedHeader(
            onLocationTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Aktueller Standort: München, Deutschland'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            bottomChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar Trigger — straddles the yellow band's bottom edge.
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: AppColors.textGrey, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Finde dein Gericht, Restaurants und Bars',
                            style: TextStyle(
                              color: AppColors.textLightGrey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ).fadeSlideUp(delay: Motion.step(1)),

                SizedBox(height: 14.h),

                // Horizontal Filter / Category Pills — these scroll off the
                // right edge in the design, so no trailing padding.
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 20.w),
                  child: Row(
                    children: [
                      // Filter Button
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const FilterModal(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                'Filter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.tune, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      _buildFilterPill(0, 'Demnächst verfügbar'),
                      const SizedBox(width: 8),
                      _buildFilterPill(1, 'Am besten bewertet'),
                      const SizedBox(width: 8),
                      _buildFilterPill(2, 'In der Nähe'),
                      SizedBox(width: 20.w),
                    ],
                  ),
                ).fadeSlideUp(delay: Motion.step(2)),
              ],
            ),
          ),

          // Main Feed of Restaurants
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await dealProvider.fetchDeals();
                await categoryProvider.fetchCategories();
              },
              color: AppColors.primary,
              child: dealProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : dealProvider.deals.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Text(
                                'Keine Restaurants gefunden.',
                                style: TextStyle(color: AppColors.textGrey),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 20.h),
                          itemCount: dealProvider.deals.length,
                          itemBuilder: (context, index) {
                            final deal = dealProvider.deals[index];
                            // Cards ease in as the feed fills.
                            return RestaurantCard(
                              deal: deal,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RestaurantDetailsScreen(deal: deal),
                                  ),
                                );
                              },
                              onDishTap: (d) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DishDetailsScreen(deal: d),
                                  ),
                                );
                              },
                            ).fadeSlideUp(delay: Motion.step(index, ms: 70, max: 5));
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(int index, String label) {
    final isSelected = _selectedFilterPill == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterPill = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF9E6) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.orangeAccent.withValues(alpha: 0.5)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textDark : AppColors.textGrey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
