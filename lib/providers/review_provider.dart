import 'package:flutter/material.dart';
import '../data/models/review_model.dart';
import '../data/repositories/review_repository.dart';
import '../core/network/api_error.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewRepository reviewRepository;

  List<ReviewModel> _reviews = [];
  final Map<String, List<ReviewModel>> _byDeal = {};
  final Map<String, int> _requests = {};
  final Set<String> _loadingDeals = {};
  final Map<String, String> _errors = {};
  List<ReviewModel> reviewsForDeal(String id) => _byDeal[id] ?? [];
  bool isLoadingFor(String id) => _loadingDeals.contains(id);
  String? errorFor(String id) => _errors[id];
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
    final request = (_requests[dealId] ?? 0) + 1;
    _requests[dealId] = request;
    _loadingDeals.add(dealId);
    _errors.remove(dealId);
    _isLoading = true;
    notifyListeners();

    try {
      final result = await reviewRepository.getReviewsByDeal(dealId);
      if (_requests[dealId] != request) return;
      _reviews = result;
      _byDeal[dealId] = result;
    } catch (error) {
      if (_requests[dealId] != request) return;
      _errors[dealId] = friendlyApiError(error);
    }
    if (_requests[dealId] != request) return;
    _loadingDeals.remove(dealId);

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
      _reviews = [
        newReview,
        ...reviewsForDeal(dealId).where((r) => r.id != newReview.id),
      ];
      _byDeal[dealId] = _reviews;
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
