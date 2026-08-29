import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/review_provider.dart';

class WriteReviewScreen extends StatefulWidget {
  final String dealId;

  const WriteReviewScreen({super.key, required this.dealId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _rating = 5;
  String? _selectedDishId;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().fetchEligibility(widget.dealId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ReviewProvider>();
    final eligibility = provider.eligibility;
    final checkInId = eligibility?.checkIn?.id;
    if (eligibility?.eligible != true ||
        checkInId == null ||
        checkInId.isEmpty) {
      _showError('Bitte checken Sie zuerst vor Ort im Restaurant ein.');
      return;
    }
    if (eligibility!.dishes.isNotEmpty && _selectedDishId == null) {
      _showError('Bitte wählen Sie das verzehrte Gericht aus.');
      return;
    }

    final success = await provider.addReview(
      dealId: widget.dealId,
      checkInId: checkInId,
      dishId: _selectedDishId,
      ratings: _rating,
      reviewComment: _commentController.text.trim(),
    );
    if (!mounted) return;
    if (!success) {
      _showError(
        provider.errorMessage ??
            'Die Bewertung konnte nicht gespeichert werden.',
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vielen Dank für Ihre Bewertung!'),
        backgroundColor: AppColors.successGreen,
      ),
    );
    Navigator.pop(context, true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.badgeRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
    final eligibility = provider.eligibility;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schildern Sie Ihre Erfahrungen',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: provider.isEligibilityLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : eligibility?.eligible != true
            ? _NotEligibleState(
                message: provider.errorMessage ?? eligibility?.message,
                onRetry: () => provider.fetchEligibility(widget.dealId),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionCard(
                        title: 'Bewertung',
                        child: Center(
                          child: RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            itemBuilder: (_, _) => const Icon(
                              Icons.star_border,
                              color: AppColors.orangeAccent,
                            ),
                            onRatingUpdate: (rating) =>
                                setState(() => _rating = rating),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _VisitCard(
                        checkedInAt: eligibility!.checkIn!.checkedInAt,
                        partySize: eligibility.checkIn!.partySize,
                      ),
                      if (eligibility.dishes.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'Verzehrtes Gericht',
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedDishId,
                            decoration: _fieldDecoration('Gericht auswählen'),
                            items: eligibility.dishes
                                .map(
                                  (dish) => DropdownMenuItem(
                                    value: dish.id,
                                    child: Text(dish.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedDishId = value),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Ihre Bewertung',
                        child: CustomTextField(
                          controller: _commentController,
                          hintText: 'Hier schreiben!',
                          maxLines: 5,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Bitte geben Sie einen Bewertungstext ein'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        text: 'Bestätigen',
                        isLoading: provider.isLoading,
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.inputBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.inputBorder),
    ),
  );
}

class _VisitCard extends StatelessWidget {
  final DateTime checkedInAt;
  final int partySize;

  const _VisitCard({required this.checkedInAt, required this.partySize});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Verifizierter Besuch',
      child: Row(
        children: [
          Expanded(
            child: _VisitValue(
              icon: Icons.calendar_today_outlined,
              label: DateFormat('dd.MM.yyyy').format(checkedInAt.toLocal()),
            ),
          ),
          Expanded(
            child: _VisitValue(
              icon: Icons.access_time,
              label: DateFormat('HH:mm').format(checkedInAt.toLocal()),
            ),
          ),
          Expanded(
            child: _VisitValue(
              icon: Icons.people_outline,
              label: '$partySize Personen',
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitValue extends StatelessWidget {
  final IconData icon;
  final String label;

  const _VisitValue({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(height: 5),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11.5, color: AppColors.textDark),
      ),
    ],
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _NotEligibleState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _NotEligibleState({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_off_outlined,
            size: 56,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Noch kein bewertbarer Check-in',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message ??
                'Checken Sie zuerst vor Ort im Restaurant ein. Danach können Sie Ihren Besuch bewerten.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut prüfen'),
          ),
        ],
      ),
    ),
  );
}
