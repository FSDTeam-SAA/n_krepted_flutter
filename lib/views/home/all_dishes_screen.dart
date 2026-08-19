import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/dish_card.dart';
import '../../providers/deal_provider.dart';
import '../dish_details/dish_details_screen.dart';

class AllDishesScreen extends StatelessWidget {
  final String categoryName;

  const AllDishesScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final dealProvider = context.watch<DealProvider>();
    final deals = dealProvider.deals;

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
          categoryName,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: deals.isEmpty
          ? const Center(
              child: Text(
                'Keine Gerichte in dieser Kategorie gefunden.',
                style: TextStyle(color: AppColors.textGrey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
                return DishCard(
                  deal: deal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DishDetailsScreen(deal: deal),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
