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
  final String category;
  final bool isSignatureDish;
  final bool isActive;

  const DealDish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.isSignatureDish,
    required this.isActive,
  });

  factory DealDish.fromJson(Map<String, dynamic> json) => DealDish(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    image: json['image'] ?? '',
    category: json['category'] ?? '',
    isSignatureDish: json['isSignatureDish'] ?? false,
    isActive: json['isActive'] ?? true,
  );
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
    this.rating = 4.5,
    this.sdRating = 4.5,
    this.reviewCount = 12,
    this.totalCheckIns = 0,
    this.distance = '6 km • 4 Meilen',
    this.duration = '20 Minuten',
    this.ingredients = const [
      'Zartes Fleischkotelett',
      'Salz und Pfeffer',
      'Paniermehl',
      'Zitrone',
      'Eier',
      'Frische Kräuter',
      'Mehl',
      'Knusprige Pommes',
    ],
    this.preparationProcess =
        'Das Fleisch wird zunächst zart geklopft, um eine saftige und zarte Konsistenz zu gewährleisten. Anschließend wird es leicht in Mehl gewendet, durch verquirlte Eier gezogen und mit feinen Semmelbröseln paniert. Das panierte Schnitzel wird goldbraun und knusprig gebraten, während es innen zart bleibt. Serviert wird es frisch mit knusprigen Pommes frites, Zitronenspalten und Kräutern.',
    this.dishes = const [],
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] is List) {
      imgList = (json['images'] as List).map((e) => e.toString()).toList();
    }
    if (imgList.isEmpty) {
      imgList = [
        'https://images.unsplash.com/photo-1599921841143-819065a55cc6?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
      ];
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
      price: (json['price'] != null)
          ? (json['price'] as num).toDouble()
          : 15.45,
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
    return 'Schnitzel';
  }

  String get firstImage => images.isNotEmpty
      ? images.first
      : 'https://images.unsplash.com/photo-1599921841143-819065a55cc6?w=600&auto=format&fit=crop&q=80';
}
