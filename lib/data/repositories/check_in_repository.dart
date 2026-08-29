import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/check_in_model.dart';

class CheckInRepository {
  final ApiClient apiClient;

  CheckInRepository({required this.apiClient});

  Future<CheckInModel> createCheckIn({
    required String restaurantId,
    required double latitude,
    required double longitude,
    required double accuracy,
    required int partySize,
  }) async {
    final response = await apiClient.post(
      ApiConstants.checkIns,
      data: {
        'restaurantId': restaurantId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'partySize': partySize,
      },
    );
    if (response.data?['success'] == true &&
        response.data?['data'] is Map<String, dynamic>) {
      return CheckInModel.fromJson(response.data['data']);
    }
    throw Exception(response.data?['message'] ?? 'Check-in fehlgeschlagen');
  }

  Future<List<CheckInModel>> getMyCheckIns() async {
    final response = await apiClient.get('${ApiConstants.checkIns}/my');
    final items = response.data?['data'];
    if (items is List) {
      return items
          .whereType<Map<String, dynamic>>()
          .map(CheckInModel.fromJson)
          .toList();
    }
    return [];
  }
}
