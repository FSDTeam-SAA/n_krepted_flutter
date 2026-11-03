import 'category_model.dart';

class DealLocation {
  final String country;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;

  DealLocation({
    this.country = '',
    this.city = '',
    this.address = '',
    this.latitude,
    this.longitude,
  });

  factory DealLocation.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return DealLocation(
        country: json['country'] ?? '',
        city: json['city'] ?? '',
        address: json['address'] ?? '',
        latitude: double.tryParse('${json['latitude']}'),
        longitude: double.tryParse('${json['longitude']}'),
      );
    }
    return DealLocation();
  }

  Map<String, dynamic> toJson() => {
    'country': country,
    'city': city,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite &&
      latitude!.abs() <= 90 &&
      longitude!.abs() <= 180;
  String get label =>
      [city, country].where((value) => value.isNotEmpty).join(', ');
}

class DealDish {
  final List<String> tags;
  final String leadImage;
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final List<String> images;
  final String category;
  final String specialtyDescription;
  final List<String> ingredients;
  final String preparationProcess;
  final bool isSignatureDish;
  final bool isActive;
  final double rating;
  final int reviewCount;

  const DealDish({
    this.tags = const [],
    this.leadImage = '',
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.images = const [],
    required this.category,
    this.specialtyDescription = '',
    this.ingredients = const [],
    this.preparationProcess = '',
    required this.isSignatureDish,
    required this.isActive,
    this.rating = 0,
    this.reviewCount = 0,
  });

  factory DealDish.fromJson(Map<String, dynamic> json) {
    final legacyImage = json['image']?.toString().trim() ?? '';
    final images = json['images'] is List
        ? (json['images'] as List)
              .map((image) => image.toString().trim())
              .where((image) => image.isNotEmpty)
              .toList()
        : <String>[];
    if (images.isEmpty && legacyImage.isNotEmpty) images.add(legacyImage);

    return DealDish(
      tags: (json['tags'] as List? ?? []).map((v) => v.toString()).toList(),
      leadImage: json['leadImage']?.toString() ?? '',
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      image: images.isNotEmpty ? images.first : legacyImage,
      images: images,
      category: json['category'] ?? '',
      specialtyDescription: json['specialtyDescription'] ?? '',
      ingredients: json['ingredients'] is List
          ? (json['ingredients'] as List)
                .map((item) => item.toString().trim())
                .where((item) => item.isNotEmpty)
                .toList()
          : const [],
      preparationProcess: json['preparationProcess'] ?? '',
      isSignatureDish: json['isSignatureDish'] ?? false,
      isActive: json['isActive'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DealModel {
  final String leadImage,
      timeZone,
      healthNotice,
      safetyComment,
      safetyDisclaimer,
      priceRange;
  final bool showTeamReviews, isOpenNow;
  final List<Map<String, dynamic>> openingHoursSchedule;
  final List<PromotionModel> promotions;
  final String id;
  final String title;
  final String? shortDescription;
  final String description;
  final double price;
  final DealLocation location;
  final List<String> images;
  final List<String> offers;
  final String status;
  final String approvalStatus;
  final String? rejectionReason;
  final String? owner;
  final CategoryModel? category;
  final List<String> categories;
  final int time;
  final double rating;
  final double sdRating;
  final int reviewCount;
  final int totalCheckIns;
  final String distance;
  final String duration;
  final List<String> ingredients;
  final String preparationProcess;
  final List<DealDish> dishes;
  final double? distanceKm;
  final DateTime? opensAt;
  final String openingHours;
  final String contactEmail;
  final String contactPhone;
  final bool? reservationRequired;
  final List<String> photoCategories;

  DealModel({
    this.leadImage = '',
    this.timeZone = 'Europe/Berlin',
    this.healthNotice = '',
    this.safetyComment = '',
    this.safetyDisclaimer = '',
    this.priceRange = r'$$',
    this.showTeamReviews = true,
    this.isOpenNow = false,
    this.openingHoursSchedule = const [],
    this.promotions = const [],
    required this.id,
    required this.title,
    this.shortDescription,
    required this.description,
    required this.price,
    required this.location,
    required this.images,
    this.offers = const [],
    this.status = 'activate',
    this.approvalStatus = 'pending',
    this.rejectionReason,
    this.owner,
    this.category,
    this.categories = const [],
    this.time = 0,
    this.rating = 0,
    this.sdRating = 0,
    this.reviewCount = 0,
    this.totalCheckIns = 0,
    this.distance = '',
    this.duration = '',
    this.ingredients = const [],
    this.preparationProcess = '',
    this.dishes = const [],
    this.distanceKm,
    this.opensAt,
    this.openingHours = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.reservationRequired,
    this.photoCategories = const [],
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] is List) {
      imgList = (json['images'] as List).map((e) => e.toString()).toList();
    }
    CategoryModel? cat;
    if (json['category'] is Map<String, dynamic>) {
      cat = CategoryModel.fromJson(json['category']);
    }

    String ownerId = '';
    if (json['owner'] is Map<String, dynamic>) {
      ownerId = json['owner']['_id'] ?? json['owner']['id'] ?? '';
    } else if (json['owner'] is String) {
      ownerId = json['owner'];
    }

    return DealModel(
      leadImage: json['leadImage']?.toString() ?? '',
      timeZone: json['timeZone']?.toString() ?? 'Europe/Berlin',
      healthNotice: json['healthNotice']?.toString() ?? '',
      safetyComment: json['safetyComment']?.toString() ?? '',
      safetyDisclaimer: json['safetyDisclaimer']?.toString() ?? '',
      priceRange: json['priceRange']?.toString() ?? r'$$',
      showTeamReviews: json['showTeamReviews'] != false,
      isOpenNow: json['isOpenNow'] == true,
      openingHoursSchedule: (json['openingHoursSchedule'] as List? ?? [])
          .whereType<Map>()
          .map((v) => Map<String, dynamic>.from(v))
          .toList(),
      promotions: (json['promotions'] as List? ?? [])
          .whereType<Map>()
          .map((v) => PromotionModel.fromJson(Map<String, dynamic>.from(v)))
          .toList(),
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'],
      description: json['description'] ?? '',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0,
      location: DealLocation.fromJson(json['location']),
      images: imgList,
      offers: json['offers'] is List
          ? (json['offers'] as List).map((e) => e.toString()).toList()
          : [],
      status: json['status'] ?? 'activate',
      approvalStatus: json['approvalStatus'] ?? 'pending',
      rejectionReason: json['rejectionReason'],
      owner: ownerId.isNotEmpty ? ownerId : null,
      category: cat,
      categories:
          (json['categories'] as List? ??
                  (cat == null ? [] : [cat.categoryName]))
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList(),
      time: json['time'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      sdRating: (json['sdRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      totalCheckIns: (json['totalCheckIns'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      opensAt: DateTime.tryParse('${json['opensAt']}'),
      openingHours: json['openingHours']?.toString() ?? '',
      contactEmail: json['contactEmail']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      reservationRequired: json['reservationRequired'] as bool?,
      photoCategories: (json['photoCategories'] as List? ?? [])
          .map((value) => value.toString())
          .toList(),
      dishes: json['dishes'] is List
          ? (json['dishes'] as List)
                .whereType<Map<String, dynamic>>()
                .map(DealDish.fromJson)
                .toList()
          : const [],
    );
  }

  bool get isApproved => approvalStatus == 'approved';
  bool get isPending => approvalStatus == 'pending';
  bool get isRejected => approvalStatus == 'rejected';

  String get restaurantName {
    return title;
  }

  String get dishName {
    return featuredDish?.name ?? '';
  }

  List<DealDish> get activeDishes =>
      dishes.where((dish) => dish.isActive).toList();
  DealDish? get featuredDish {
    final active = activeDishes;
    for (final dish in active) {
      if (dish.isSignatureDish) return dish;
    }
    return active.isEmpty ? null : active.first;
  }

  String get discoveryImage =>
      featuredDish?.image.isNotEmpty == true ? featuredDish!.image : firstImage;
  bool get isUpcoming => opensAt?.isAfter(DateTime.now()) == true;

  String get firstImage => leadImage.isNotEmpty && images.contains(leadImage)
      ? leadImage
      : images.isNotEmpty
      ? images.first
      : '';
}

class PromotionModel {
  final String title, text, bannerUrl, discountType, dishId;
  final double discountValue;
  final DateTime? endsAt;
  const PromotionModel({
    required this.title,
    required this.text,
    required this.bannerUrl,
    required this.discountType,
    required this.discountValue,
    required this.dishId,
    this.endsAt,
  });
  factory PromotionModel.fromJson(Map<String, dynamic> json) => PromotionModel(
    title: json['title']?.toString() ?? '',
    text: json['text']?.toString() ?? '',
    bannerUrl: json['bannerUrl']?.toString() ?? '',
    discountType: json['discountType']?.toString() ?? 'none',
    discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
    dishId: json['dish']?.toString() ?? '',
    endsAt: DateTime.tryParse('${json['endsAt']}'),
  );
  double price(double original) =>
      (discountType == 'percent'
              ? original * (1 - discountValue / 100)
              : discountType == 'amount'
              ? original - discountValue
              : original)
          .clamp(0, double.infinity);
}
