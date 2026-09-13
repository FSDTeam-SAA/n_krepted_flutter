import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../data/models/deal_model.dart';
import '../../providers/location_provider.dart';
import '../../providers/saved_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class RemotePhoto extends StatelessWidget {
  final String url;
  final BoxFit fit;
  const RemotePhoto(this.url, {super.key, this.fit = BoxFit.cover});
  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: const Color(0xFFF1F1EF),
      child: const Center(
        child: Icon(
          Icons.restaurant_outlined,
          color: AppColors.textGrey,
          size: 30,
        ),
      ),
    );
    return url.isEmpty
        ? placeholder
        : CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            placeholder: (_, _) => placeholder,
            errorWidget: (_, _, _) => placeholder,
          );
  }
}

class SaveButton extends StatelessWidget {
  final DealModel restaurant;
  final String? dishId;
  final bool compact;
  const SaveButton({
    super.key,
    required this.restaurant,
    this.dishId,
    this.compact = false,
  });
  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    return IconButton(
      constraints: compact
          ? const BoxConstraints.tightFor(width: 32, height: 32)
          : null,
      padding: compact ? const EdgeInsets.all(3) : null,
      tooltip: saved.isSaved(restaurant.id, dishId: dishId)
          ? 'Entfernen'
          : 'Speichern',
      visualDensity: VisualDensity.compact,
      icon: Icon(
        saved.isSaved(restaurant.id, dishId: dishId)
            ? Icons.favorite
            : Icons.favorite_border,
        color: AppColors.primary,
        size: compact ? 21 : 24,
      ),
      onPressed: saved.isPending(restaurant.id, dishId: dishId)
          ? null
          : () async {
              final success = await saved.toggleSave(
                restaurant,
                dishId: dishId,
              );
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      saved.errorMessage ?? 'Speichern fehlgeschlagen.',
                    ),
                  ),
                );
              }
            },
    );
  }
}

class DistanceLine extends StatelessWidget {
  final DealModel restaurant;
  final bool compact;
  const DistanceLine(this.restaurant, {super.key, this.compact = false});
  @override
  Widget build(BuildContext context) {
    final position = context.watch<LocationProvider?>()?.position;
    double? km = restaurant.distanceKm;
    if (position != null && restaurant.location.hasCoordinates) {
      km =
          Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            restaurant.location.latitude!,
            restaurant.location.longitude!,
          ) /
          1000;
    }
    if (km == null || !km.isFinite || km < 0) {
      if (!compact) return const SizedBox.shrink();
      return Tooltip(
        message:
            'Für die Entfernung werden Ihr Standort und Restaurantkoordinaten benötigt.',
        child: Row(
          children: [
            const Icon(
              Icons.route_outlined,
              size: 11,
              color: AppColors.textGrey,
            ),
            const SizedBox(width: 3),
            const Flexible(
              child: Text(
                'Entfernung nicht verfügbar',
                style: TextStyle(
                  fontSize: AppFontSizes.micro,
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final format = NumberFormat(
      '0.#',
      Localizations.localeOf(context).languageCode,
    );
    final miles = Localizations.localeOf(context).languageCode == 'de'
        ? 'Meilen'
        : 'mi';
    return Tooltip(
      message: 'Luftlinie, keine berechnete Gehroute',
      child: Wrap(
        spacing: compact ? 4 : 7,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: compact ? 11 : 13,
            color: AppColors.textGrey,
          ),
          Text(
            '${format.format(km)} km',
            style: TextStyle(
              fontSize: compact
                  ? AppFontSizes.micro
                  : AppFontSizes.captionSmall,
              color: AppColors.textGrey,
            ),
          ),
          Text(
            '•',
            style: TextStyle(
              fontSize: compact
                  ? AppFontSizes.micro
                  : AppFontSizes.captionSmall,
              color: AppColors.textGrey,
            ),
          ),
          Text(
            '${format.format(km / 1.609344)} $miles',
            style: TextStyle(
              fontSize: compact
                  ? AppFontSizes.micro
                  : AppFontSizes.captionSmall,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class DataState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const DataState(this.message, {super.key, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            onRetry == null ? Icons.restaurant_menu : Icons.cloud_off,
            color: AppColors.textGrey,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut versuchen'),
            ),
        ],
      ),
    ),
  );
}
