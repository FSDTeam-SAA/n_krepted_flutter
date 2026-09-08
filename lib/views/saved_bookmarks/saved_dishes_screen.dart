import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../core/widgets/discovery_widgets.dart';
import '../../core/widgets/restaurant_card.dart';
import '../../providers/saved_provider.dart';
import '../dish_details/dish_details_screen.dart';
import '../restaurant_details/restaurant_details_screen.dart';

class SavedDishesScreen extends StatefulWidget {
  final bool active;
  const SavedDishesScreen({super.key, this.active = true});
  @override
  State<SavedDishesScreen> createState() => _SavedDishesScreenState();
}

class _SavedDishesScreenState extends State<SavedDishesScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reload();
  }

  void _reload() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.active) {
        context.read<SavedProvider>().loadSavedDeals();
      }
    });
  }

  @override
  void didUpdateWidget(covariant SavedDishesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _reload();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gespeichert'),
        automaticallyImplyLeading: false,
      ),
      body: OwnerPageBackground(
        child: saved.isLoading
            ? const Center(child: CircularProgressIndicator())
            : saved.errorMessage != null
            ? DataState(saved.errorMessage!, onRetry: saved.loadSavedDeals)
            : saved.entries.isEmpty
            ? const DataState(
                'Noch keine Restaurants oder Gerichte gespeichert.',
              )
            : RefreshIndicator(
                onRefresh: saved.loadSavedDeals,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: saved.entries.length,
                  itemBuilder: (context, index) {
                    final entry = saved.entries[index];
                    return RestaurantCard(
                      deal: entry.restaurant,
                      dish: entry.dish,
                      compact: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => entry.dish != null
                              ? DishDetailsScreen(
                                  deal: entry.restaurant,
                                  dish: entry.dish,
                                )
                              : RestaurantDetailsScreen(deal: entry.restaurant),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
