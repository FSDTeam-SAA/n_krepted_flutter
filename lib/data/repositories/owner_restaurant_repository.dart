import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/deal_model.dart';

class OwnerDashboardStats {
  final int totalCheckIns;
  final int totalCustomers;
  final int totalDeals;
  final int totalReviews;
  final int activeDeals;

  const OwnerDashboardStats({
    this.totalCheckIns = 0,
    this.totalCustomers = 0,
    this.totalDeals = 0,
    this.totalReviews = 0,
    this.activeDeals = 0,
  });

  factory OwnerDashboardStats.fromJson(Map<String, dynamic> json) {
    return OwnerDashboardStats(
      totalCheckIns: (json['totalCheckIns'] as num?)?.toInt() ?? 0,
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
      totalDeals: (json['totalDeals'] as num?)?.toInt() ?? 0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      activeDeals: (json['activeDeals'] as num?)?.toInt() ?? 0,
    );
  }
}

class OwnerRestaurantRepository {
  final ApiClient apiClient;

  OwnerRestaurantRepository({required this.apiClient});

  Future<FormData> _restaurantFormData(Map<String, dynamic> payload) async {
    final fields = Map<String, dynamic>.from(payload);
    final imageFiles =
        (fields.remove('imageFiles') as List?)?.whereType<XFile>().toList() ??
        const <XFile>[];
    fields['location'] = jsonEncode(fields['location']);
    fields['existingImages'] = jsonEncode(
      (fields['existingImages'] as List?)?.whereType<String>().toList() ??
          const <String>[],
    );

    final formData = FormData.fromMap(fields);
    for (final image in imageFiles) {
      formData.files.add(
        MapEntry(
          'images',
          MultipartFile.fromBytes(
            await image.readAsBytes(),
            filename: image.name,
          ),
        ),
      );
    }
    return formData;
  }

  Future<FormData> _dishFormData(Map<String, dynamic> payload) async {
    final fields = Map<String, dynamic>.from(payload);
    final imageFiles =
        (fields.remove('imageFiles') as List?)?.whereType<XFile>().toList() ??
        const <XFile>[];
    fields['existingImages'] = jsonEncode(
      (fields['existingImages'] as List?)?.whereType<String>().toList() ??
          const <String>[],
    );
    fields['ingredients'] = jsonEncode(
      (fields['ingredients'] as List?)?.whereType<String>().toList() ??
          const <String>[],
    );
    final formData = FormData.fromMap(fields);
    for (final image in imageFiles) {
      formData.files.add(
        MapEntry(
          'images',
          MultipartFile.fromBytes(
            await image.readAsBytes(),
            filename: image.name,
          ),
        ),
      );
    }
    return formData;
  }

  Future<DealModel?> getMyRestaurant() async {
    final response = await apiClient.get(ApiConstants.ownerRestaurant);
    if (response.data != null &&
        response.data['restaurant'] is Map<String, dynamic>) {
      return DealModel.fromJson(response.data['restaurant']);
    }
    return null;
  }

  Future<OwnerDashboardStats> getDashboardStats() async {
    final response = await apiClient.get(ApiConstants.dashboardStats);
    final data = response.data?['data'];
    if (data is Map<String, dynamic>) {
      return OwnerDashboardStats.fromJson(data);
    }
    return const OwnerDashboardStats();
  }

  Future<DealModel> submitRestaurant(Map<String, dynamic> payload) async {
    final response = await apiClient.post(
      ApiConstants.ownerRestaurant,
      data: await _restaurantFormData(payload),
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.data != null && response.data['restaurant'] != null) {
      return DealModel.fromJson(response.data['restaurant']);
    }
    throw Exception('Restaurant konnte nicht eingereicht werden');
  }

  Future<DealModel> resubmitRestaurant(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await apiClient.put(
      '${ApiConstants.ownerRestaurant}/$id',
      data: await _restaurantFormData(payload),
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.data != null && response.data['restaurant'] != null) {
      return DealModel.fromJson(response.data['restaurant']);
    }
    throw Exception('Restaurant konnte nicht erneut eingereicht werden');
  }

  Future<DealModel> updateRestaurant(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await apiClient.put(
      '${ApiConstants.adminRestaurants}/$id',
      data: await _restaurantFormData(payload),
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.data != null && response.data['restaurant'] != null) {
      return DealModel.fromJson(response.data['restaurant']);
    }
    throw Exception('Restaurantangaben konnten nicht aktualisiert werden');
  }

  Future<DealModel> addDish(
    String restaurantId,
    Map<String, dynamic> payload,
  ) async {
    final response = await apiClient.post(
      '${ApiConstants.restaurants}/$restaurantId/dishes',
      data: await _dishFormData(payload),
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.data != null && response.data['restaurant'] != null) {
      return DealModel.fromJson(response.data['restaurant']);
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
      data: await _dishFormData(payload),
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.data != null && response.data['restaurant'] != null) {
      return DealModel.fromJson(response.data['restaurant']);
    }
    throw Exception('Gericht konnte nicht aktualisiert werden');
  }

  Future<DealModel> deleteDish(String restaurantId, String dishId) async {
    final response = await apiClient.delete(
      '${ApiConstants.restaurants}/$restaurantId/dishes/$dishId',
    );
    if (response.data != null && response.data['restaurant'] != null) {
      return DealModel.fromJson(response.data['restaurant']);
    }
    throw Exception('Gericht konnte nicht gelöscht werden');
  }
}
