import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/review_card.dart';
import '../../providers/review_provider.dart';
import 'write_review_screen.dart';

class AllReviewsScreen extends StatelessWidget {
  final String dealId;

  const AllReviewsScreen({super.key, required this.dealId});

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
          'Alle Bewertungen',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review_outlined, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WriteReviewScreen(dealId: dealId),
                ),
              );
            },
          ),
        ],
      ),
      body: reviewProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : reviewProvider.reviews.isEmpty
              ? const Center(
                  child: Text(
                    'Keine Bewertungen vorhanden.',
                    style: TextStyle(color: AppColors.textGrey),
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
