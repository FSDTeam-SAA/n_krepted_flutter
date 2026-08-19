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
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String dId = '';
    String? rName;
    String? dImg;
    if (json['dealID'] is Map<String, dynamic>) {
      dId = json['dealID']['_id'] ?? '';
      rName = json['dealID']['title'];
      if (json['dealID']['images'] is List && (json['dealID']['images'] as List).isNotEmpty) {
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
      dishName: 'Schnitzel',
      reviewComment: json['reviewComment'] ?? '',
      ratings: (json['ratings'] != null) ? (json['ratings'] as num).toDouble() : 5.0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      dishImage: dImg,
    );
  }
}
