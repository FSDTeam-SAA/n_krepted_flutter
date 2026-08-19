import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Datenschutzrichtlinie',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Datenschutz auf einen Blick',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              SizedBox(height: 8),
              Text(
                'Wir nehmen den Schutz Ihrer persönlichen Daten sehr ernst. Wir behandeln Ihre personenbezogenen Daten vertraulich und entsprechend den gesetzlichen Datenschutzvorschriften sowie dieser Datenschutzerklärung.',
                style: TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.5),
              ),
              SizedBox(height: 18),
              Text(
                '2. Datenerfassung in unserer App',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              SizedBox(height: 8),
              Text(
                'Die Datenverarbeitung in dieser App erfolgt durch den App-Betreiber. Ihre Daten werden zum einen dadurch erhoben, dass Sie uns diese mitteilen (z. B. bei der Registrierung oder Reservierung). Andere Daten werden automatisch beim Besuch der App erfasst (z. B. Standortdaten zur Restaurantsuche).',
                style: TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.5),
              ),
              SizedBox(height: 18),
              Text(
                '3. Ihre Rechte',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              SizedBox(height: 8),
              Text(
                'Sie haben jederzeit das Recht auf unentgeltliche Auskunft über Ihre gespeicherten personenbezogenen Daten, deren Herkunft und Empfänger und den Zweck der Datenverarbeitung sowie ein Recht auf Berichtigung oder Löschung dieser Daten.',
                style: TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
