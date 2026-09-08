import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
