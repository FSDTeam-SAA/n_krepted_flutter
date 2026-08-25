import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/deal_model.dart';

class OwnerRestaurantRepository {
  final ApiClient apiClient;

  OwnerRestaurantRepository({required this.apiClient});

  Future<DealModel?> getMyRestaurant() async {
    try {
      final response = await apiClient.get(ApiConstants.ownerRestaurant);
      if (response.data != null &&
          response.data['data'] != null &&
          response.data['data'] is Map<String, dynamic>) {
        return DealModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      // 404 or no restaurant yet
      return null;
    }
  }

  Future<DealModel> submitRestaurant(Map<String, dynamic> payload) async {
    final response = await apiClient.post(
      ApiConstants.ownerRestaurant,
      data: payload,
    );
    if (response.data != null && response.data['data'] != null) {
      return DealModel.fromJson(response.data['data']);
    }
    throw Exception('Restaurant konnte nicht eingereicht werden');
  }

  Future<DealModel> resubmitRestaurant(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await apiClient.put(
      '${ApiConstants.ownerRestaurant}/$id',
      data: payload,
    );
    if (response.data != null && response.data['data'] != null) {
      return DealModel.fromJson(response.data['data']);
    }
    throw Exception('Restaurant konnte nicht erneut eingereicht werden');
  }

  Future<DealModel> updateRestaurant(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await apiClient.put(
      '${ApiConstants.adminRestaurants}/$id',
      data: payload,
    );
    if (response.data != null && response.data['data'] != null) {
      return DealModel.fromJson(response.data['data']);
    }
    throw Exception('Restaurantangaben konnten nicht aktualisiert werden');
  }

  Future<DealModel> addDish(
    String restaurantId,
    Map<String, dynamic> payload,
  ) async {
    final response = await apiClient.post(
      '${ApiConstants.restaurants}/$restaurantId/dishes',
      data: payload,
    );
    if (response.data != null && response.data['data'] != null) {
      return DealModel.fromJson(response.data['data']);
    }
    throw Exception('Gericht konnte nicht hinzugefügt werden');
  }

  Future<DealModel> updateDish(
    String restaurantId,
    String dishId,
    Map<String, dynamic> payload,
  ) async {
    final response = await apiClient.put(
      '${ApiConstants.restaurants}/$restaurantId/dishes/$dishId',
      data: payload,
    );
    if (response.data != null && response.data['data'] != null) {
      return DealModel.fromJson(response.data['data']);
    }
    throw Exception('Gericht konnte nicht aktualisiert werden');
  }

  Future<DealModel> deleteDish(String restaurantId, String dishId) async {
    final response = await apiClient.delete(
      '${ApiConstants.restaurants}/$restaurantId/dishes/$dishId',
    );
    if (response.data != null && response.data['data'] != null) {
      return DealModel.fromJson(response.data['data']);
    }
    throw Exception('Gericht konnte nicht gelöscht werden');
  }
}
