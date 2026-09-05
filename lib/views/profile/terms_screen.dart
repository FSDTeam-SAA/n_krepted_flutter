import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_language_provider.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../core/widgets/legal_document_body.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          language.text('Geschäftsbedingungen', 'Terms and conditions'),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: OwnerPageBackground(
        child: LegalDocumentBody(
          type: LegalDocumentType.terms,
          fallbackText: language.text(
            'Durch den Zugriff auf und die Nutzung dieser Anwendung erklären Sie sich mit diesen Nutzungsbedingungen einverstanden. Die App dient dazu, Nutzern Informationen, Bilder, Beschreibungen und Empfehlungen zu Gerichten von Restaurants und Bars bereitzustellen. Die in der App angezeigten Inhalte dienen ausschließlich Informations- und Recherchezwecken und stellen kein Angebot zum Verkauf von Speisen, Getränken oder Dienstleistungen über die Plattform dar.\n\nNutzer sind selbst dafür verantwortlich, alle Informationen direkt beim jeweiligen Restaurant oder der jeweiligen Bar zu überprüfen, bevor sie auf Grundlage der bereitgestellten Inhalte Entscheidungen treffen. Sie verpflichten sich, die App nicht zu missbrauchen, keinen unbefugten Zugriff zu versuchen, ihre Funktionalität nicht zu beeinträchtigen oder die Plattform für rechtswidrige Aktivitäten zu nutzen.\n\nAlle in der App angezeigten Inhalte, Marken, Logos und geistigen Eigentumsrechte bleiben Eigentum ihrer jeweiligen Inhaber. Obwohl wir uns bemühen, die Informationen korrekt und aktuell zu halten, übernehmen wir keine Gewähr für die Vollständigkeit, Richtigkeit oder Verfügbarkeit der Inhalte. Wir behalten uns das Recht vor, Teile der App jederzeit ohne vorherige Ankündigung zu ändern, zu aktualisieren, auszusetzen oder einzustellen. Die fortgesetzte Nutzung der App gilt als Zustimmung zu allen Aktualisierungen dieser Nutzungsbedingungen.',
            'By accessing and using this application, you agree to these terms of use. The app provides users with information, images, descriptions, and recommendations for dishes from restaurants and bars. Content displayed in the app is provided solely for informational and research purposes and does not constitute an offer to sell food, drinks, or services through the platform.\n\nUsers are responsible for verifying all information directly with the relevant restaurant or bar before making decisions based on the provided content. You agree not to misuse the app, attempt unauthorized access, interfere with its functionality, or use the platform for unlawful activities.\n\nAll content, trademarks, logos, and intellectual-property rights displayed in the app remain the property of their respective owners. Although we aim to keep information accurate and current, we do not guarantee its completeness, accuracy, or availability. We reserve the right to change, update, suspend, or discontinue any part of the app without prior notice. Continued use of the app constitutes acceptance of updates to these terms.',
          ),
        ),
      ),
    );
  }
}
