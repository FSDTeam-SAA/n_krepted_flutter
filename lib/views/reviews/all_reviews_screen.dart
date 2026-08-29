import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/review_card.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_language_provider.dart';
import 'write_review_screen.dart';

class AllReviewsScreen extends StatefulWidget {
  final String dealId;

  const AllReviewsScreen({super.key, required this.dealId});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().fetchReviewsForDeal(widget.dealId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final authProvider = context.watch<AuthProvider>();
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
          language.text('Alle Bewertungen', 'All reviews'),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: authProvider.currentUser?.role == 'user'
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.rate_review_outlined,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WriteReviewScreen(
                          dealId: widget.dealId,
                        ),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: reviewProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : reviewProvider.reviews.isEmpty
              ? Center(
                  child: Text(
                    language.text(
                      'Keine Bewertungen vorhanden.',
                      'No reviews yet.',
                    ),
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: reviewProvider.reviews.length,
                  itemBuilder: (context, index) {
                    return ReviewCard(review: reviewProvider.reviews[index]);
                  },
                ),
    );
  }
}
