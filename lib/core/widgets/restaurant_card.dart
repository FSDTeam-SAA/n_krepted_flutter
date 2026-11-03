import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/deal_model.dart';
import '../constants/app_colors.dart';
import 'discovery_widgets.dart';
import 'rating_badge.dart';
import 'feature_content.dart';
import '../constants/app_text_styles.dart';

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
    final featured = dish;
    final upcoming = deal.isUpcoming;
    final signatures = deal.activeDishes
        .where((item) => item.isSignatureDish)
        .take(3)
        .toList();
    final photo = featured?.image ?? deal.discoveryImage;
    final image = Stack(
      fit: StackFit.expand,
      children: [
        RemotePhoto(photo, fit: BoxFit.cover),
        if (featured?.isSignatureDish == true ||
            (featured == null && deal.featuredDish?.isSignatureDish == true))
          const Positioned(left: 8, top: 8, child: SignatureBadge()),
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
                          fontSize: compact
                              ? AppFontSizes.tiny
                              : AppFontSizes.small,
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
      padding: EdgeInsets.all(compact ? 12 : 16),
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
                    fontSize: compact
                        ? AppFontSizes.body
                        : AppFontSizes.titleLarge,
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
                        fontSize: compact
                            ? AppFontSizes.tiny
                            : AppFontSizes.labelSmall,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          DistanceLine(deal, compact: compact),
          if (!compact && featured != null) FoodTags(featured.tags),
          SizedBox(height: compact ? 4 : 6),
          Wrap(
            spacing: 5,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    deal.rating.toStringAsFixed(1).replaceAll('.', ','),
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: AppFontSizes.small,
                    ),
                  ),
                  const Icon(Icons.star, color: AppColors.starYellow, size: 13),
                ],
              ),
              if (!compact) ...[
                Text(
                  '${deal.reviewCount} Bewertungen',
                  style: const TextStyle(fontSize: AppFontSizes.captionSmall),
                ),
              ],
            ],
          ),
          if (upcoming && deal.opensAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${DateFormat('dd.MM.yyyy · HH:mm').format(deal.opensAt!.toLocal())} · Demnächst verfügbar',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSizes.small,
                ),
              ),
            ),
          if (compact && dish == null && signatures.isNotEmpty) ...[
            const SizedBox(height: 8),
            _signaturePreviews(signatures),
          ],
          if (!compact && showMore && !upcoming) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
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
      padding: const EdgeInsets.only(bottom: 16),
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
                        width: (constraints.maxWidth * .35).clamp(88.0, 132.0),
                        height: 132,
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
                    if (dish == null && signatures.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: _signaturePreviews(signatures),
                      ),
                    info,
                  ],
                ),
        ),
      ),
    );
  }

  Widget _signaturePreviews(List<DealDish> signatures) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var index = 0; index < 3; index++) ...[
        if (index > 0) const SizedBox(width: 8),
        if (index >= signatures.length)
          const Spacer()
        else
          Expanded(
            child: InkWell(
              key: ValueKey('signature-preview-${signatures[index].id}'),
              onTap: onDishTap == null
                  ? onTap
                  : () => onDishTap!(signatures[index]),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1.2,
                      child: RemotePhoto(signatures[index].image),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    signatures[index].name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact
                          ? AppFontSizes.tiny
                          : AppFontSizes.small,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ],
  );
}
