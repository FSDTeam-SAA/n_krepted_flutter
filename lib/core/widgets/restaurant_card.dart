import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/deal_model.dart';
import '../constants/app_colors.dart';
import 'discovery_widgets.dart';
import 'rating_badge.dart';

/// The same database restaurant/dish pair is used in Home, Search, Saved and Map.
class RestaurantCard extends StatelessWidget {
  final DealModel deal;
  final DealDish? dish;
  final VoidCallback? onTap;
  final ValueChanged<DealDish>? onDishTap;
  final bool compact;
  final bool showMore;
  const RestaurantCard({
    super.key,
    required this.deal,
    this.dish,
    this.onTap,
    this.onDishTap,
    this.compact = false,
    this.showMore = true,
  });

  @override
  Widget build(BuildContext context) {
    final featured = dish ?? deal.featuredDish;
    final upcoming = deal.isUpcoming;
    final photo = upcoming
        ? deal.firstImage
        : featured?.image ?? deal.firstImage;
    final image = Stack(
      fit: StackFit.expand,
      children: [
        RemotePhoto(photo, fit: BoxFit.contain),
        if (!upcoming && featured != null) ...[
          Positioned(
            top: compact ? 5 : 8,
            right: compact ? 5 : 8,
            child: RatingBadge(rating: featured.rating),
          ),
          Positioned(
            left: compact ? 4 : 10,
            right: compact ? 4 : 10,
            bottom: compact ? 4 : 8,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .42),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        featured.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 10 : 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
    final info = Padding(
      padding: EdgeInsets.all(compact ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deal.restaurantName,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 14 : 19,
                  ),
                ),
              ),
              SaveButton(restaurant: deal, dishId: dish?.id, compact: compact),
            ],
          ),
          if (deal.location.label.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: compact ? 4 : 7),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: compact ? 11 : 15,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      deal.location.label,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 10 : 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          DistanceLine(deal, compact: compact),
          SizedBox(height: compact ? 4 : 6),
          Row(
            children: [
              Text(
                deal.rating.toStringAsFixed(1).replaceAll('.', ','),
                style: const TextStyle(color: Color(0xFFA4B600), fontSize: 12),
              ),
              const Icon(Icons.star, color: Color(0xFFA4B600), size: 13),
              if (!compact) ...[
                const SizedBox(width: 5),
                Text(
                  '${deal.reviewCount} Bewertungen',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ],
          ),
          if (upcoming && deal.opensAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${DateFormat('dd.MM.yyyy · HH:mm').format(deal.opensAt!.toLocal())} · Demnächst verfügbar',
                style: const TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
          if (!compact && showMore && !upcoming) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cyan),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Mehr anzeigen'),
              ),
            ),
          ],
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 20 : 22),
      child: Material(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: compact
              ? LayoutBuilder(
                  builder: (context, constraints) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: (constraints.maxWidth * .43).clamp(100.0, 152.0),
                        height: 118,
                        child: image,
                      ),
                      Expanded(child: info),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: GestureDetector(
                        onTap: featured != null && onDishTap != null
                            ? () => onDishTap!(featured)
                            : onTap,
                        child: image,
                      ),
                    ),
                    info,
                  ],
                ),
        ),
      ),
    );
  }
}
