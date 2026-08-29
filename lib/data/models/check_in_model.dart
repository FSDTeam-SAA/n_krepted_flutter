import 'deal_model.dart';

class CheckInModel {
  final String id;
  final String userId;
  final String restaurantId;
  final DealModel? restaurant;
  final DateTime checkedInAt;
  final int partySize;
  final double distanceMeters;
  final String status;

  const CheckInModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.restaurant,
    required this.checkedInAt,
    required this.partySize,
    required this.distanceMeters,
    required this.status,
  });

  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['userId'];
    final rawRestaurant = json['restaurantId'];
    return CheckInModel(
      id: json['_id']?.toString() ?? '',
      userId: rawUser is Map
          ? rawUser['_id']?.toString() ?? ''
          : rawUser?.toString() ?? '',
      restaurantId: rawRestaurant is Map
          ? rawRestaurant['_id']?.toString() ?? ''
          : rawRestaurant?.toString() ?? '',
      restaurant: rawRestaurant is Map<String, dynamic>
          ? DealModel.fromJson(rawRestaurant)
          : null,
      checkedInAt:
          DateTime.tryParse(json['checkedInAt']?.toString() ?? '') ??
          DateTime.now(),
      partySize: (json['partySize'] as num?)?.toInt() ?? 1,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'verified',
    );
  }
}
