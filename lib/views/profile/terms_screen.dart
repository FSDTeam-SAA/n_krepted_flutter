import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Geschäftsbedingungen',
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
                '1. Geltungsbereich',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              SizedBox(height: 8),
              Text(
                'Diese Allgemeinen Geschäftsbedingungen gelten für alle Nutzer der Signature Dish Applikation. Mit der Nutzung der App erklären Sie sich mit diesen Bedingungen einverstanden.',
                style: TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.5),
              ),
              SizedBox(height: 18),
              Text(
                '2. Reservierungen und Check-ins',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              SizedBox(height: 8),
              Text(
                'Über unsere Plattform vermittelte Reservierungen und Check-ins sind verbindlich. Bei Nichterscheinen behalten sich die Partnerrestaurants das Recht vor, entsprechende Stornierungsbedingungen anzuwenden.',
                style: TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.5),
              ),
              SizedBox(height: 18),
              Text(
                '3. Bewertungen',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              SizedBox(height: 8),
              Text(
                'Nutzer verpflichten sich, sachliche und wahrheitsgemäße Bewertungen abzugeben. Beleidigende oder geschäftsschädigende Inhalte werden unverzüglich entfernt.',
                style: TextStyle(fontSize: 13, color: AppColors.textBody, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
