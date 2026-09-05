import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_language_provider.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../core/widgets/legal_document_body.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          language.text('Datenschutzrichtlinie', 'Privacy policy'),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: OwnerPageBackground(
        child: LegalDocumentBody(
          type: LegalDocumentType.privacy,
          fallbackText: language.text(
            'Ihre Privatsphäre ist uns wichtig. Diese Datenschutzrichtlinie erklärt, wie wir Informationen erfassen, verwenden und schützen, wenn Sie die Anwendung nutzen. Die App kann begrenzte Informationen wie Kontodaten, Geräteinformationen, Nutzungsanalysen und Präferenzen erfassen, um die Leistung zu verbessern, die Benutzerfreundlichkeit zu optimieren und die Sicherheit zu gewährleisten.\n\nDie Anwendung verarbeitet keine Zahlungen, ermöglicht keine Käufe und erfasst keine Finanzinformationen, da sie ausschließlich als Plattform zum Entdecken und Ansehen von Gerichten aus Restaurants und Bars dient. Wir verkaufen oder vermieten keine personenbezogenen Daten an Dritte. Informationen werden nur dann an vertrauenswürdige Dienstleister weitergegeben, wenn dies für den Betrieb, die Wartung oder die Verbesserung der App erforderlich ist oder wenn dies gesetzlich vorgeschrieben ist.\n\nWir setzen angemessene Sicherheitsmaßnahmen zum Schutz von Benutzerinformationen ein; jedoch kann keine Methode der elektronischen Speicherung oder Übertragung absolute Sicherheit garantieren. Durch die Nutzung der App stimmen Sie der Erfassung und Verwendung von Informationen gemäß dieser Datenschutzrichtlinie zu.\n\nWir behalten uns das Recht vor, diese Richtlinie regelmäßig zu aktualisieren. Die fortgesetzte Nutzung der App nach Änderungen gilt als Zustimmung zur geänderten Datenschutzrichtlinie.',
            'Your privacy is important to us. This privacy policy explains how we collect, use, and protect information when you use the application. The app may collect limited information such as account data, device information, usage analytics, and preferences to improve performance, usability, and security.\n\nThe application does not process payments, enable purchases, or collect financial information. It is solely a platform for discovering and viewing dishes from restaurants and bars. We do not sell or rent personal data to third parties. Information is shared with trusted service providers only when required to operate, maintain, or improve the app, or when required by law.\n\nWe use reasonable safeguards to protect user information; however, no method of electronic storage or transmission can guarantee absolute security. By using the app, you consent to the collection and use of information in accordance with this privacy policy.\n\nWe reserve the right to update this policy periodically. Continued use of the app after changes constitutes acceptance of the revised privacy policy.',
          ),
        ),
      ),
    );
  }
}
