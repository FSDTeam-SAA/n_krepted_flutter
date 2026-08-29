import 'package:flutter/material.dart';
import '../data/models/review_model.dart';
import '../data/repositories/review_repository.dart';
import '../core/network/api_error.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewRepository reviewRepository;

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  bool _isEligibilityLoading = false;
  ReviewEligibility? _eligibility;
  String? _errorMessage;

  ReviewProvider({required this.reviewRepository});

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isEligibilityLoading => _isEligibilityLoading;
  ReviewEligibility? get eligibility => _eligibility;
  String? get errorMessage => _errorMessage;

  Future<void> fetchEligibility(String dealId) async {
    _isEligibilityLoading = true;
    _errorMessage = null;
    _eligibility = null;
    notifyListeners();
    try {
      _eligibility = await reviewRepository.getEligibility(dealId);
    } catch (error) {
      _errorMessage = friendlyApiError(
        error,
        fallback: 'Die Check-in-Berechtigung konnte nicht geprüft werden.',
      );
    } finally {
      _isEligibilityLoading = false;
      notifyListeners();
    }
  }

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
    required String checkInId,
    String? dishId,
    required double ratings,
    required String reviewComment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newReview = await reviewRepository.createReview(
        dealId: dealId,
        checkInId: checkInId,
        dishId: dishId,
        ratings: ratings,
        reviewComment: reviewComment,
      );
      _reviews.insert(0, newReview);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = friendlyApiError(
        error,
        fallback: 'Die Bewertung konnte nicht gespeichert werden.',
      );
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
