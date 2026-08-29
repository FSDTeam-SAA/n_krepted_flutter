import 'deal_model.dart';

class ReviewVisitModel {
  final String id;
  final DateTime checkedInAt;
  final int partySize;
  final double distanceMeters;

  const ReviewVisitModel({
    required this.id,
    required this.checkedInAt,
    required this.partySize,
    required this.distanceMeters,
  });

  factory ReviewVisitModel.fromJson(Map<String, dynamic> json) =>
      ReviewVisitModel(
        id: json['_id']?.toString() ?? '',
        checkedInAt:
            DateTime.tryParse(json['checkedInAt']?.toString() ?? '') ??
            DateTime.now(),
        partySize: (json['partySize'] as num?)?.toInt() ?? 1,
        distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      );
}

class ReviewEligibility {
  final bool eligible;
  final ReviewVisitModel? checkIn;
  final List<DealDish> dishes;
  final String message;

  const ReviewEligibility({
    required this.eligible,
    this.checkIn,
    this.dishes = const [],
    this.message = '',
  });

  factory ReviewEligibility.fromJson(Map<String, dynamic> json) {
    final rawCheckIn = json['checkIn'];
    final rawRestaurant = rawCheckIn is Map ? rawCheckIn['restaurantId'] : null;
    final rawDishes = rawRestaurant is Map ? rawRestaurant['dishes'] : null;
    return ReviewEligibility(
      eligible: json['eligible'] == true,
      checkIn: rawCheckIn is Map<String, dynamic>
          ? ReviewVisitModel.fromJson(rawCheckIn)
          : null,
      dishes: rawDishes is List
          ? rawDishes
                .whereType<Map<String, dynamic>>()
                .map(DealDish.fromJson)
                .where((dish) => dish.isActive)
                .toList()
          : const [],
      message: json['message']?.toString() ?? '',
    );
  }
}

class ReviewUserModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;

  ReviewUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory ReviewUserModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ReviewUserModel(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['name'] ?? 'Nita Money',
        email: json['email'] ?? 'nitabani@gmail.com',
        avatar: json['avatar'],
      );
    }
    return ReviewUserModel(
      id: 'default',
      name: 'Nita Money',
      email: 'nitabani@gmail.com',
    );
  }
}

class ReviewModel {
  final String id;
  final ReviewUserModel user;
  final String dealId;
  final String? restaurantName;
  final String? dishName;
  final String reviewComment;
  final double ratings;
  final DateTime createdAt;
  final String? dishImage;
  final ReviewVisitModel? checkIn;

  ReviewModel({
    required this.id,
    required this.user,
    required this.dealId,
    this.restaurantName,
    this.dishName,
    required this.reviewComment,
    this.ratings = 5.0,
    required this.createdAt,
    this.dishImage,
    this.checkIn,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String dId = '';
    String? rName;
    String? dImg;
    if (json['dealID'] is Map<String, dynamic>) {
      dId = json['dealID']['_id'] ?? '';
      rName = json['dealID']['title'];
      if (json['dealID']['images'] is List &&
          (json['dealID']['images'] as List).isNotEmpty) {
        dImg = json['dealID']['images'][0];
      }
    } else if (json['dealID'] is String) {
      dId = json['dealID'];
    }

    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      user: ReviewUserModel.fromJson(json['userID']),
      dealId: dId,
      restaurantName: rName ?? 'Restaurant JAN',
      dishName: json['dishName']?.toString(),
      reviewComment: json['reviewComment'] ?? '',
      ratings: (json['ratings'] != null)
          ? (json['ratings'] as num).toDouble()
          : 5.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      dishImage: dImg,
      checkIn: json['checkInID'] is Map<String, dynamic>
          ? ReviewVisitModel.fromJson(json['checkInID'])
          : null,
    );
  }
}
