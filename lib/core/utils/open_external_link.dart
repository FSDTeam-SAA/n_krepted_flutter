import 'package:flutter/material.dart';
import '../../data/models/deal_model.dart';
import 'package:url_launcher/url_launcher.dart';

String googleMapsDirections(DealModel restaurant) =>
    Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': restaurant.location.hasCoordinates
          ? '${restaurant.location.latitude},${restaurant.location.longitude}'
          : restaurant.location.address,
      'travelmode': 'walking',
    }).toString();

Future<void> openExternalLink(BuildContext context, String value) async {
  final uri = Uri.tryParse(value);
  try {
    if (uri != null &&
        ['https', 'http', 'tel', 'mailto'].contains(uri.scheme) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    }
  } catch (_) {
    /* Show the same actionable failure for unsupported devices. */
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dieser Link konnte nicht geöffnet werden.'),
      ),
    );
  }
}
