import 'category_model.dart';

class DealLocation {
  final String country;
  final String city;

  DealLocation({
    this.country = 'Deutschland',
    this.city = 'München',
  });

  factory DealLocation.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return DealLocation(
        country: json['country'] ?? 'Deutschland',
        city: json['city'] ?? 'München',
      );
    }
    return DealLocation();
  }

  Map<String, dynamic> toJson() => {'country': country, 'city': city};
}

class DealScheduleDate {
  final DateTime date;
  final bool active;
  final int participationsLimit;
  final int bookedCount;

  DealScheduleDate({
    required this.date,
    this.active = true,
    this.participationsLimit = 20,
    this.bookedCount = 0,
  });

  factory DealScheduleDate.fromJson(Map<String, dynamic> json) {
    return DealScheduleDate(
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      active: json['active'] ?? true,
      participationsLimit: json['participationsLimit'] ?? 20,
      bookedCount: json['bookedCount'] ?? 0,
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
  final CategoryModel? category;
  final int time;
  final double rating;
  final double sdRating;
  final int reviewCount;
  final String distance;
  final String duration;
  final List<DealScheduleDate> scheduleDates;
  final List<String> ingredients;
  final String preparationProcess;

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
    this.category,
    this.time = 45,
    this.rating = 4.5,
    this.sdRating = 4.5,
    this.reviewCount = 12,
    this.distance = '6 km • 4 Meilen',
    this.duration = '20 Minuten',
    this.scheduleDates = const [],
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

    List<DealScheduleDate> schedules = [];
    if (json['scheduleDates'] is List) {
      schedules = (json['scheduleDates'] as List)
          .map((s) => s is Map<String, dynamic> ? DealScheduleDate.fromJson(s) : null)
          .whereType<DealScheduleDate>()
          .toList();
    }

    return DealModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'],
      description: json['description'] ?? '',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 15.45,
      location: DealLocation.fromJson(json['location']),
      images: imgList,
      offers: json['offers'] is List ? (json['offers'] as List).map((e) => e.toString()).toList() : [],
      status: json['status'] ?? 'activate',
      category: cat,
      time: json['time'] ?? 45,
      rating: 4.8,
      sdRating: 4.5,
      reviewCount: 12,
      scheduleDates: schedules,
    );
  }

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
