import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../data/models/deal_model.dart';
import '../../providers/owner_restaurant_provider.dart';
import 'create_edit_restaurant_screen.dart';
import 'dish_form_sheet.dart';

class OwnerWorkspaceScreen extends StatefulWidget {
  const OwnerWorkspaceScreen({super.key});

  @override
  State<OwnerWorkspaceScreen> createState() => _OwnerWorkspaceScreenState();
}

class _OwnerWorkspaceScreenState extends State<OwnerWorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerRestaurantProvider>().fetchMyRestaurant();
    });
  }

  void _openAddDishSheet([DealDish? dish]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DishFormSheet(dish: dish),
    );
  }

  void _confirmDeleteDish(DealDish dish) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gericht löschen'),
        content: Text('Möchten Sie „${dish.name}“ wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<OwnerRestaurantProvider>();
              final success = await provider.deleteDish(dish.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Gericht gelöscht.'
                          : provider.errorMessage ?? 'Fehler beim Löschen.',
                    ),
                    backgroundColor:
                        success ? AppColors.primary : AppColors.badgeRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);
    final provider = context.watch<OwnerRestaurantProvider>();
    final restaurant = provider.restaurant;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Restaurantverwaltung',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => provider.fetchMyRestaurant(),
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchMyRestaurant(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _buildBody(provider, restaurant),
              ),
            ),
    );
  }

  Widget _buildBody(OwnerRestaurantProvider provider, DealModel? restaurant) {
    // 1. No restaurant yet
    if (restaurant == null) {
      return _buildNoRestaurantView();
    }

    // 2. Pending Approval
    if (restaurant.isPending) {
      return _buildPendingView(restaurant);
    }

    // 3. Rejected by Admin
    if (restaurant.isRejected) {
      return _buildRejectedView(restaurant);
    }

    // 4. Approved & Live
    return _buildApprovedView(restaurant);
  }

  Widget _buildNoRestaurantView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 30),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.storefront, size: 50, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Eigenes Restaurant registrieren',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Reichen Sie Ihr Restaurant ein, um Spezialitäten, Öffnungszeiten und Signature Dishes für Kunden in Ihrer Nähe sichtbar zu machen.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.textGrey,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 36),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_business, color: Colors.white),
          label: const Text(
            'Restaurant jetzt erstellen',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateEditRestaurantScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPendingView(DealModel restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFEEFB3), width: 1.5),
          ),
          child: Column(
            children: [
              const Icon(Icons.schedule, color: Colors.amber, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Wartet auf Genehmigung',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ihr Restaurant „${restaurant.title}“ wurde erfolgreich eingereicht. Ein Administrator prüft die Angaben. Sobald es genehmigt ist, können Sie Gerichte verwalten.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFFB45309), height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildRestaurantSummaryCard(restaurant),
      ],
    );
  }

  Widget _buildRejectedView(DealModel restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 48),
              const SizedBox(height: 12),
              Text(
                'Restaurant wurde abgelehnt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ablehnungsgrund: ${restaurant.rejectionReason ?? "Keine Angabe"}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade800,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text(
            'Überarbeiten und erneut einreichen',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateEditRestaurantScreen(
                  restaurant: restaurant,
                  isResubmission: true,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildRestaurantSummaryCard(restaurant),
      ],
    );
  }

  Widget _buildApprovedView(DealModel restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live Restaurant Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: restaurant.firstImage,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.restaurant, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: const Text(
                                'Genehmigt',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${restaurant.location.address}, ${restaurant.location.city}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Startpreis: €${restaurant.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                label: const Text(
                  'Restaurantangaben bearbeiten',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateEditRestaurantScreen(restaurant: restaurant),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Dishes Header & Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gerichte & Spezialitäten',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${restaurant.dishes.length} Gerichte hinterlegt',
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text(
                'Hinzufügen',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _openAddDishSheet(),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (restaurant.dishes.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: const [
                Icon(Icons.restaurant_menu, size: 40, color: AppColors.textGrey),
                SizedBox(height: 12),
                Text(
                  'Noch keine Gerichte vorhanden',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                SizedBox(height: 4),
                Text(
                  'Fügen Sie Ihre ersten Gerichte und Signature Dishes hinzu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: restaurant.dishes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final dish = restaurant.dishes[index];
              return _buildDishCard(dish);
            },
          ),
      ],
    );
  }

  Widget _buildDishCard(DealDish dish) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dish.isSignatureDish ? const Color(0xFFFEEFB3) : AppColors.cardBorder,
          width: dish.isSignatureDish ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: dish.image.isNotEmpty
                  ? dish.image
                  : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 58,
                height: 58,
                color: Colors.grey.shade200,
                child: const Icon(Icons.fastfood, color: Colors.grey, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dish.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (dish.isSignatureDish)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBE7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFEEFB3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 11),
                            SizedBox(width: 2),
                            Text(
                              'Signature',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '€${dish.price.toStringAsFixed(2)} • ${dish.category.isNotEmpty ? dish.category : "Hauptspeise"}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (dish.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    dish.description,
                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textGrey),
            onPressed: () => _openAddDishSheet(dish),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.badgeRed),
            onPressed: () => _confirmDeleteDish(dish),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSummaryCard(DealModel restaurant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Eingereichte Restaurantdetails',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Name', restaurant.title),
          _buildInfoRow('Startpreis', '€${restaurant.price.toStringAsFixed(2)}'),
          _buildInfoRow('Standort', '${restaurant.location.address}, ${restaurant.location.city}'),
          if (restaurant.description.isNotEmpty)
            _buildInfoRow('Beschreibung', restaurant.description),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
