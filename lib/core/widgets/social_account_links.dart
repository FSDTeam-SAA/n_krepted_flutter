import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'provider_brand_icon.dart';

class SocialAccountLinks extends StatelessWidget {
  const SocialAccountLinks({super.key});
  Future<void> _link(BuildContext context, String provider) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.socialLogin(provider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Konto erfolgreich verknüpft.'
                : auth.errorMessage ?? 'Verknüpfung fehlgeschlagen.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().isLoading;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
            icon: const GoogleBrandIcon(),
            onPressed: busy ? null : () => _link(context, 'google'),
            label: const Text('Google-Konto verknüpfen'),
          ),
          if (!kIsWeb &&
              [
                TargetPlatform.iOS,
                TargetPlatform.android,
              ].contains(defaultTargetPlatform))
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
              icon: const AppleBrandIcon(),
              onPressed: busy ? null : () => _link(context, 'apple'),
              label: const Text('Apple-Konto verknüpfen'),
            ),
        ],
      ),
    );
  }
}
