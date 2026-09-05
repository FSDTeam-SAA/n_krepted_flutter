import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/deal_model.dart';

class DealRepository {
  final ApiClient apiClient;

  DealRepository({required this.apiClient});

  Future<List<DealModel>> getAllDeals({
    String? categoryId,
    String? search,
    String? city,
    String? country,
    String? location,
    double? latitude,
    double? longitude,
    double? radiusKm,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> query = {'page': page, 'limit': limit};
    if (categoryId != null && categoryId.isNotEmpty) {
      query['category'] = categoryId;
    }
    if (search != null && search.isNotEmpty) {
      query['title'] = search;
    }
    if (city != null && city.trim().isNotEmpty) query['city'] = city.trim();
    if (country != null && country.trim().isNotEmpty) {
      query['country'] = country.trim();
    }
    if (location != null && location.trim().isNotEmpty) {
      query['location'] = location.trim();
    }
    if (latitude != null && longitude != null) {
      query['latitude'] = latitude;
      query['longitude'] = longitude;
      query['radiusKm'] = radiusKm ?? 25;
    }

    final response = await apiClient.get(
      ApiConstants.deals,
      queryParameters: query,
    );

    if (response.data != null && response.data['deals'] is List) {
      return (response.data['deals'] as List)
          .map((item) => DealModel.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<DealModel> getDealById(String id) async {
    final response = await apiClient.get('${ApiConstants.deals}/$id');
    if (response.data != null && response.data['deal'] != null) {
      return DealModel.fromJson(response.data['deal']);
    }
    throw Exception('Deal nicht gefunden');
  }

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await apiClient.get(ApiConstants.categories);
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => CategoryModel.fromJson(item))
            .toList();
      }
    } catch (_) {}

    return [];
  }
}
