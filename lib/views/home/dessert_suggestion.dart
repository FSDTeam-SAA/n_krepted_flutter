import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../providers/deal_provider.dart';
import '../../providers/location_provider.dart';
import 'discovery_feed.dart';

/// Offered after a completed visit review, only when nearby DB results exist.
Future<void> showDessertSuggestion(BuildContext context) async {
  final position = context.read<LocationProvider>().position;
  if (position == null) return;
  final repository = context.read<DealProvider>().dealRepository;
  try {
    final nearby = await repository.getAllDeals(
      latitude: position.latitude,
      longitude: position.longitude,
      radiusKm: .5,
      recommendation: 'dessert',
      limit: 1,
    );
    if (nearby.isEmpty ||
        !context.mounted ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    final explore = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Column(
          children: [
            Icon(Icons.local_cafe_outlined, size: 48, color: AppColors.primary),
            SizedBox(height: 16),
            Text('Lust auf ein Dessert?', textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          'Entdecken Sie Dessert- und Kaffeelokale in Ihrer Nähe (bis zu 500 m Luftlinie).',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGrey, height: 1.5),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Später'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Erkunden'),
          ),
        ],
      ),
    );
    if (explore != true || !context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) =>
              DealProvider(dealRepository: repository, autoLoad: false)
                ..recommendation = 'dessert'
                ..applyFilters(
                  location: '',
                  radiusKm: .5,
                  minimumRating: 0,
                  sort: 'nearest',
                  latitude: position.latitude,
                  longitude: position.longitude,
                ),
          child: Scaffold(
            appBar: AppBar(title: const Text('Dessert & Kaffee')),
            body: const OwnerPageBackground(child: DiscoveryFeed()),
          ),
        ),
      ),
    );
  } catch (_) {
    // Optional suggestions never turn a successfully saved review into an error.
  }
}
