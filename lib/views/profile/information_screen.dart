import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/legal_document_body.dart';
import '../../data/repositories/site_content_repository.dart';
import '../../core/utils/open_external_link.dart';

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Impressum')),
    body: const LegalDocumentBody(type: LegalDocumentType.impressum),
  );
}

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override
  State<ContactScreen> createState() => _ContactState();
}

class _ContactState extends State<ContactScreen> {
  late Future<Map<String, dynamic>> _settings = SiteContentRepository()
      .getSettings();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kontakt')),
    body: SafeArea(
      top: false,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _settings,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => setState(
                  () => _settings = SiteContentRepository().getSettings(),
                ),
                child: const Text('Erneut versuchen'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = snapshot.data!;
          final email = s['contactEmail']?.toString() ?? '';
          final phone = s['contactPhone']?.toString() ?? '';
          final address = s['contactAddress']?.toString() ?? '';
          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              if (email.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(email),
                  onTap: () => openExternalLink(
                    context,
                    Uri(scheme: 'mailto', path: email).toString(),
                  ),
                ),
              if (phone.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(phone),
                  onTap: () => openExternalLink(
                    context,
                    Uri(scheme: 'tel', path: phone).toString(),
                  ),
                ),
              if (address.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(address),
                ),
              if ([email, phone, address].every((v) => v.isEmpty))
                const Text('Kontaktdaten werden in Kürze veröffentlicht.'),
            ],
          );
        },
      ),
    ),
  );
}
