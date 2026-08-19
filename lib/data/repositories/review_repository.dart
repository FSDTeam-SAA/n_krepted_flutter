import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final ApiClient apiClient;

  ReviewRepository({required this.apiClient});

  Future<List<ReviewModel>> getReviewsByDeal(String dealId) async {
    final response = await apiClient.get('${ApiConstants.reviews}/deal/$dealId');
    if (response.data != null && response.data['reviews'] is List) {
      return (response.data['reviews'] as List)
          .map((item) => ReviewModel.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<List<ReviewModel>> getAllReviews() async {
    final response = await apiClient.get(ApiConstants.reviews);
    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((item) => ReviewModel.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<ReviewModel> createReview({
    required String dealId,
    required String userId,
    required double ratings,
    required String reviewComment,
  }) async {
    final response = await apiClient.post(
      ApiConstants.reviews,
      data: {
        'dealID': dealId,
        'userID': userId,
        'ratings': ratings,
        'reviewComment': reviewComment,
      },
    );

    if (response.data != null && response.data['success'] == true) {
      return ReviewModel.fromJson(response.data['data']);
    }
    throw Exception(response.data?['message'] ?? 'Fehler beim Erstellen der Bewertung');
  }
}
