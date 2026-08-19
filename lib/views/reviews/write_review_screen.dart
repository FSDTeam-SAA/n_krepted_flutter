import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';

class WriteReviewScreen extends StatefulWidget {
  final String dealId;

  const WriteReviewScreen({super.key, required this.dealId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final reviewProvider = context.read<ReviewProvider>();
    final userId = authProvider.currentUser?.id ?? '6a852dd213d863acd80c9b08';

    final success = await reviewProvider.addReview(
      dealId: widget.dealId,
      userId: userId,
      ratings: _rating,
      reviewComment: _commentController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vielen Dank für Ihre Bewertung!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reviewProvider.reviews.isEmpty ? 'Fehler beim Erstellen der Bewertung.' : 'Erfolgreich hinzugefügt!'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();

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
          'Bewertung schreiben',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                const Text(
                  'Wie war Ihr Erlebnis?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Bewerten Sie Qualität, Service und Geschmack für die Community.',
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Star Rating Bar
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: AppColors.orangeAccent,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() => _rating = rating);
                  },
                ),

                const SizedBox(height: 32),

                // Comment Text Field
                CustomTextField(
                  controller: _commentController,
                  hintText: 'Schildern Sie Ihre Erfahrungen ausführlich...',
                  labelText: 'Ihre Bewertung',
                  maxLines: 5,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Bitte geben Sie einen Bewertungstext ein';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 36),

                CustomButton(
                  text: 'Bewertung abschicken',
                  isLoading: reviewProvider.isLoading,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
