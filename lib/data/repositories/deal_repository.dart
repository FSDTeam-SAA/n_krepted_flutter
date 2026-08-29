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

    // Fallback default German cuisine categories matching design
    return [
      CategoryModel(
        id: 'cat-1',
        categoryName: 'Schnitzel',
        image:
            'https://images.unsplash.com/photo-1599921841143-819065a55cc6?w=400&auto=format&fit=crop&q=80',
      ),
      CategoryModel(
        id: 'cat-2',
        categoryName: 'Steak',
        image:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&auto=format&fit=crop&q=80',
      ),
      CategoryModel(
        id: 'cat-3',
        categoryName: 'Traditionell',
        image:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&auto=format&fit=crop&q=80',
      ),
      CategoryModel(
        id: 'cat-4',
        categoryName: 'Gourmet',
        image:
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&auto=format&fit=crop&q=80',
      ),
      CategoryModel(
        id: 'cat-5',
        categoryName: 'Desserts',
        image:
            'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400&auto=format&fit=crop&q=80',
      ),
    ];
  }
}
