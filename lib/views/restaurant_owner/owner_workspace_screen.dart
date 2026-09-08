import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/deal_model.dart';
import '../../providers/owner_restaurant_provider.dart';
import 'create_edit_restaurant_screen.dart';
import 'dish_form_sheet.dart';
import 'owner_dishes_screen.dart';

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
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
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
                    backgroundColor: success
                        ? AppColors.primary
                        : AppColors.badgeRed,
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
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildBody(provider, restaurant),
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
      return _buildPendingView(provider, restaurant);
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
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.storefront,
              size: 50,
              color: AppColors.primary,
            ),
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateEditRestaurantScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPendingView(
    OwnerRestaurantProvider provider,
    DealModel restaurant,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFCF0), Color(0xFFFFF7DC)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFE295)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD875)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        size: 13,
                        color: Color(0xFFB45309),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'PRÜFUNG LÄUFT',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.7,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD45C), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.manage_search_rounded,
                  color: Color(0xFFF2A900),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ihre Anfrage wird geprüft',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '„${restaurant.title}“ wurde erfolgreich eingereicht. '
                'Nach der Freigabe können Sie Gerichte und Restaurantdetails verwalten.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF7C5A25),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(
                    child: _ApprovalStep(
                      icon: Icons.check_rounded,
                      label: 'Eingereicht',
                      isComplete: true,
                    ),
                  ),
                  _ApprovalConnector(isComplete: true),
                  Expanded(
                    child: _ApprovalStep(
                      icon: Icons.search_rounded,
                      label: 'In Prüfung',
                      isActive: true,
                    ),
                  ),
                  _ApprovalConnector(),
                  Expanded(
                    child: _ApprovalStep(
                      icon: Icons.storefront_rounded,
                      label: 'Online',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () => provider.fetchMyRestaurant(),
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: const Text('Status aktualisieren'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  foregroundColor: AppColors.primaryDark,
                  backgroundColor: Colors.white.withValues(alpha: 0.72),
                  side: const BorderSide(color: AppColors.primary),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildRestaurantSummaryCard(restaurant),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: AppColors.textGrey,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'Sie werden nach der Entscheidung automatisch informiert.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
              ),
            ),
          ],
        ),
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
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFA7F3D0),
                                ),
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
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${restaurant.location.address}, ${restaurant.location.city}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Startpreis: ${formatEuro(context, restaurant.price)}',
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
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Restaurantangaben bearbeiten',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CreateEditRestaurantScreen(restaurant: restaurant),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OwnerDishesScreen()),
                ),
                icon: const Icon(Icons.grid_view_outlined, size: 17),
                label: const Text('Alle Gerichte'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const OwnerDishesScreen(signaturesOnly: true),
                  ),
                ),
                icon: const Icon(Icons.star_outline, size: 18),
                label: const Text('Spezialitäten'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

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
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text(
                'Hinzufügen',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                Icon(
                  Icons.restaurant_menu,
                  size: 40,
                  color: AppColors.textGrey,
                ),
                SizedBox(height: 12),
                Text(
                  'Noch keine Gerichte vorhanden',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
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
          color: dish.isSignatureDish
              ? const Color(0xFFFEEFB3)
              : AppColors.cardBorder,
          width: dish.isSignatureDish ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: dish.image,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
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
                  '${formatEuro(context, dish.price)} • ${dish.category.isNotEmpty ? dish.category : "Hauptspeise"}',
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
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.textGrey,
            ),
            onPressed: () => _openAddDishSheet(dish),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppColors.badgeRed,
            ),
            onPressed: () => _confirmDeleteDish(dish),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSummaryCard(DealModel restaurant) {
    final location = [
      restaurant.location.address,
      restaurant.location.city,
    ].where((part) => part.trim().isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Eingereichte Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: restaurant.firstImage,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: 82,
                    height: 82,
                    color: AppColors.primaryLight,
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryLine(
                      Icons.location_on_outlined,
                      location.isEmpty ? 'Kein Standort angegeben' : location,
                    ),
                    const SizedBox(height: 6),
                    _buildSummaryLine(
                      Icons.payments_outlined,
                      'Ab ${formatEuro(context, restaurant.price)}',
                      valueColor: AppColors.primaryDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (restaurant.description.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),
            Text(
              restaurant.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryLine(
    IconData icon,
    String value, {
    Color valueColor = AppColors.textGrey,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ApprovalStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isComplete;
  final bool isActive;

  const _ApprovalStep({
    required this.icon,
    required this.label,
    this.isComplete = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = isComplete || isActive;
    final color = isComplete
        ? AppColors.successGreen
        : isActive
        ? const Color(0xFFF2A900)
        : const Color(0xFFC7B98F);

    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: highlighted ? Colors.white : const Color(0xFFFFF9E8),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: highlighted ? 1.7 : 1),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            color: highlighted ? AppColors.textBody : AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

class _ApprovalConnector extends StatelessWidget {
  final bool isComplete;

  const _ApprovalConnector({this.isComplete = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 1.5,
      margin: const EdgeInsets.only(bottom: 22),
      color: isComplete
          ? AppColors.successGreen.withValues(alpha: 0.55)
          : const Color(0xFFE8DDBB),
    );
  }
}
