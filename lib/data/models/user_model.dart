class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final bool isVerified;
  final String? avatar;
  final String? country;
  final String? cityState;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.role = 'user',
    this.isVerified = true,
    this.avatar,
    this.country,
    this.cityState,
    this.token,
  });

  bool get isRestaurantOwner => role == 'restaurant_owner';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 'user',
      isVerified: json['isVerified'] ?? true,
      avatar: json['avatar'],
      country: json['country'],
      cityState: json['cityState'],
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'isVerified': isVerified,
      'avatar': avatar,
      'country': country,
      'cityState': cityState,
      'token': token,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? avatar,
    String? country,
    String? cityState,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      isVerified: isVerified,
      avatar: avatar ?? this.avatar,
      country: country ?? this.country,
      cityState: cityState ?? this.cityState,
      token: token,
    );
  }
}
