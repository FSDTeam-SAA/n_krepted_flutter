import 'category_model.dart';

class DealLocation {
  final String country;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;

  DealLocation({
    this.country = 'Deutschland',
    this.city = 'München',
    this.address = '',
    this.latitude,
    this.longitude,
  });

  factory DealLocation.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return DealLocation(
        country: json['country'] ?? 'Deutschland',
        city: json['city'] ?? 'München',
        address: json['address'] ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
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
}

class DealDish {
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

  const DealDish({
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
    );
  }
}

class DealModel {
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

  DealModel({
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
    this.time = 45,
    this.rating = 0,
    this.sdRating = 0,
    this.reviewCount = 0,
    this.totalCheckIns = 0,
    this.distance = '',
    this.duration = '',
    this.ingredients = const [],
    this.preparationProcess = '',
    this.dishes = const [],
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
      time: json['time'] ?? 45,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      sdRating: (json['sdRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      totalCheckIns: (json['totalCheckIns'] as num?)?.toInt() ?? 0,
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
    if (title.contains('-')) {
      return title.split('-').first.trim();
    }
    return title;
  }

  String get dishName {
    if (title.contains('-')) {
      return title.split('-').last.trim();
    }
    return title;
  }

  String get firstImage => images.isNotEmpty ? images.first : '';
}
