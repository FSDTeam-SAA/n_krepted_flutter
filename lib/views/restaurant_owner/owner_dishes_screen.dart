import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/deal_model.dart';
import '../../providers/owner_restaurant_provider.dart';
import '../dish_details/dish_details_screen.dart';
import 'dish_form_sheet.dart';

class OwnerDishesScreen extends StatefulWidget {
  final bool signaturesOnly;

  const OwnerDishesScreen({super.key, this.signaturesOnly = false});

  @override
  State<OwnerDishesScreen> createState() => _OwnerDishesScreenState();
}

class _OwnerDishesScreenState extends State<OwnerDishesScreen> {
  String _category = '';

  void _showForm([DealDish? dish]) => showModalBottomSheet<void>(
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OwnerRestaurantProvider>();
    final restaurant = provider.restaurant;
    final source =
        restaurant?.dishes
            .where((dish) => !widget.signaturesOnly || dish.isSignatureDish)
            .toList() ??
        const <DealDish>[];
    final categories = source
        .map((dish) => dish.category.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
    final dishes = _category.isEmpty
        ? source
        : source.where((dish) => dish.category == _category).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.signaturesOnly ? 'Spezialitäten' : 'Alle Gerichte',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showForm(),
            icon: const Icon(Icons.add, color: AppColors.primary, size: 27),
            tooltip: 'Gericht hinzufügen',
          ),
        ],
      ),
      body: restaurant == null
          ? const Center(child: Text('Restaurant nicht gefunden.'))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: provider.fetchMyRestaurant,
              child: CustomScrollView(
                slivers: [
                  if (!widget.signaturesOnly && categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 53,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 7,
                          ),
                          scrollDirection: Axis.horizontal,
                          children: [
                            _CategoryChip(
                              label: 'Alle',
                              selected: _category.isEmpty,
                              onTap: () => setState(() => _category = ''),
                            ),
                            ...categories.map(
                              (category) => _CategoryChip(
                                label: category,
                                selected: _category == category,
                                onTap: () =>
                                    setState(() => _category = category),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (dishes.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.restaurant_menu,
                                size: 45,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.signaturesOnly
                                    ? 'Noch keine Spezialitäten vorhanden.'
                                    : 'Noch keine Gerichte vorhanden.',
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () => _showForm(),
                                icon: const Icon(Icons.add),
                                label: const Text('Gericht hinzufügen'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (widget.signaturesOnly)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                      sliver: SliverList.separated(
                        itemCount: dishes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 18),
                        itemBuilder: (_, index) => _SignatureCard(
                          restaurant: restaurant,
                          dish: dishes[index],
                          onEdit: () => _showForm(dishes[index]),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.03,
                            ),
                        itemCount: dishes.length,
                        itemBuilder: (_, index) => _DishGridTile(
                          restaurant: restaurant,
                          dish: dishes[index],
                          onEdit: () => _showForm(dishes[index]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFFFF7D8),
      backgroundColor: const Color(0xFFF4F3F5),
      side: BorderSide.none,
      labelStyle: TextStyle(
        color: selected ? AppColors.textDark : AppColors.textGrey,
        fontSize: 11.5,
      ),
    ),
  );
}

class _DishGridTile extends StatelessWidget {
  final DealModel restaurant;
  final DealDish dish;
  final VoidCallback onEdit;

  const _DishGridTile({
    required this.restaurant,
    required this.dish,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DishDetailsScreen(deal: restaurant, dish: dish),
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: const Color(0xFFF3F4F6),
            child: CachedNetworkImage(
              imageUrl: dish.image,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) =>
                  const Icon(Icons.restaurant_menu, color: AppColors.textGrey),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 35,
            bottom: 9,
            child: Text(
              dish.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 16),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SignatureCard extends StatelessWidget {
  final DealModel restaurant;
  final DealDish dish;
  final VoidCallback onEdit;

  const _SignatureCard({
    required this.restaurant,
    required this.dish,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    clipBehavior: Clip.antiAlias,
    elevation: 1,
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
                imageUrl: dish.image,
                width: double.infinity,
                height: 250,
                fit: BoxFit.contain,
                errorWidget: (_, _, _) => const SizedBox(
                  height: 250,
                  child: Center(child: Icon(Icons.restaurant_menu)),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton.filledTonal(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 6),
                  Text(
                    dish.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
                const SizedBox(height: 9),
                Text(
                  '€${dish.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
