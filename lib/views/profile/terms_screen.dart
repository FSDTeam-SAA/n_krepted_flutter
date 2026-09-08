import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_language_provider.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../core/widgets/legal_document_body.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        context.watch<AppLanguageProvider>().text(
          'Geschäftsbedingungen',
          'Terms and conditions',
        ),
        style: const TextStyle(fontSize: 18),
      ),
    ),
    body: const OwnerPageBackground(
      child: LegalDocumentBody(type: LegalDocumentType.terms),
    ),
  );
}
