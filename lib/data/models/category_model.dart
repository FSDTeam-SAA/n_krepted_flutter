class CategoryModel {
  final String id;
  final String categoryName;
  final String? image;

  CategoryModel({
    required this.id,
    required this.categoryName,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryName': categoryName,
      'image': image,
    };
  }
}
