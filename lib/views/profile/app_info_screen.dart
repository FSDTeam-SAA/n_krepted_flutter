import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_brand_logo.dart';
import 'information_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  PackageInfo? _package;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _package = info);
    } catch (_) {
      // The rest of the page remains available if platform metadata is missing.
    }
  }

  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _openSettings() async {
    try {
      if (await Geolocator.openAppSettings()) return;
    } catch (_) {
      // Some desktop platforms cannot open per-app settings.
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte öffne die App-Einstellungen auf deinem Gerät.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F8F9),
    appBar: AppBar(
      backgroundColor: const Color(0xFFF6F8F9),
      title: const Text('App-Info'),
    ),
    body: SafeArea(
      top: false,
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF4BF), Color(0xFFE5F5F7)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .85),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const AppBrandLogo(width: 108),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Signature Dish',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFontSizes.displaySmall,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Besondere Gerichte. Neue Lieblingsorte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    color: AppColors.textBody,
                    height: 1.5,
                  ),
                ),
                if (_package != null && _package!.version.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Version ${_package!.version}${_package!.buildNumber.isEmpty ? '' : ' · Build ${_package!.buildNumber}'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppFontSizes.small,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _heading('Dein nächstes Geschmackserlebnis'),
          const SizedBox(height: 12),
          _card([
            _feature(
              Icons.explore_outlined,
              'Entdecken',
              'Finde Restaurants und ihre besonderen Signature-Gerichte.',
            ),
            const Divider(height: 1, indent: 64),
            _feature(
              Icons.favorite_border_rounded,
              'Merken',
              'Speichere Lieblingsgerichte und Orte für deinen nächsten Besuch.',
            ),
            const Divider(height: 1, indent: 64),
            _feature(
              Icons.rate_review_outlined,
              'Erleben',
              'Checke vor Ort ein und teile deine Erfahrungen.',
            ),
          ]),
          const SizedBox(height: 24),
          _heading('Support & Informationen'),
          const SizedBox(height: 12),
          _card([
            _link(
              Icons.contact_support_outlined,
              'Kontakt & Hilfe',
              'Wir sind für dich da',
              () => _open(const ContactScreen()),
            ),
            const Divider(height: 1, indent: 64),
            _link(
              Icons.business_outlined,
              'Impressum',
              null,
              () => _open(const ImpressumScreen()),
            ),
            const Divider(height: 1, indent: 64),
            _link(
              Icons.shield_outlined,
              'Datenschutzerklärung',
              null,
              () => _open(const PrivacyPolicyScreen()),
            ),
            const Divider(height: 1, indent: 64),
            _link(
              Icons.description_outlined,
              'Geschäftsbedingungen',
              null,
              () => _open(const TermsScreen()),
            ),
            const Divider(height: 1, indent: 64),
            _link(
              Icons.code_rounded,
              'Open-Source-Lizenzen',
              null,
              () => showLicensePage(
                context: context,
                applicationName: 'Signature Dish',
                applicationVersion: _package?.version,
                applicationIcon: const Padding(
                  padding: EdgeInsets.all(16),
                  child: AppBrandLogo(width: 78),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dein Standort ist optional',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Du kannst auch ohne Standort nach Städten suchen. Für Restaurants in deiner Nähe und Check-ins vor Ort wird dein Standort benötigt.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textBody,
                  ),
                ),
                if (!kIsWeb) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: _openSettings,
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    label: const Text('App-Einstellungen öffnen'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mit Appetit auf Neues.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ],
      ),
    ),
  );

  Widget _heading(String title) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );

  Widget _card(List<Widget> children) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(children: children),
  );

  Widget _icon(IconData icon) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, size: 20, color: AppColors.primaryDark),
  );

  Widget _feature(IconData icon, String title, String description) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _link(
    IconData icon,
    String title,
    String? subtitle,
    VoidCallback onTap,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    leading: _icon(icon),
    title: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    subtitle: subtitle == null
        ? null
        : Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
    trailing: const Icon(
      Icons.chevron_right_rounded,
      size: 20,
      color: AppColors.textGrey,
    ),
    onTap: onTap,
  );
}
