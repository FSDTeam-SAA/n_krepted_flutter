import 'package:flutter/material.dart';
import '../data/models/review_model.dart';
import '../data/repositories/review_repository.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewRepository reviewRepository;

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  ReviewProvider({required this.reviewRepository});

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviewsForDeal(String dealId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reviews = await reviewRepository.getReviewsByDeal(dealId);
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReview({
    required String dealId,
    required String userId,
    required double ratings,
    required String reviewComment,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newReview = await reviewRepository.createReview(
        dealId: dealId,
        userId: userId,
        ratings: ratings,
        reviewComment: reviewComment,
      );
      _reviews.insert(0, newReview);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
