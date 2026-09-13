import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    if (response.data != null && response.data['success'] == true) {
      final token = response.data['token'];
      final userMap = response.data['data'];
      final user = UserModel.fromJson(userMap, token: token);

      await StorageService.saveToken(token);
      await StorageService.saveUser(user.toJson());
      return user;
    } else {
      throw Exception(response.data?['message'] ?? 'Anmeldung fehlgeschlagen');
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    bool isRestaurantOwner = false,
  }) async {
    final response = await apiClient.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'role': isRestaurantOwner ? 'restaurant_owner' : 'user',
      },
    );

    if (response.data != null && response.data['success'] == true) {
      if (isRestaurantOwner) {
        return login(email: email, password: password);
      }
      final userMap = response.data['data'];
      final token = response.data['token'];
      final user = UserModel.fromJson(userMap, token: token);
      if (token != null) {
        await StorageService.saveToken(token);
        await StorageService.saveUser(user.toJson());
      }
      return user;
    } else {
      throw Exception(
        response.data?['message'] ?? 'Registrierung fehlgeschlagen',
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await apiClient.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    if (response.data?['success'] != true) {
      throw Exception(
        response.data?['message'] ??
            'Der Bestätigungscode konnte nicht gesendet werden.',
      );
    }
  }

  Future<UserModel> verifyOtp({
    required String email,
    required String code,
  }) async {
    final response = await apiClient.post(
      ApiConstants.verifyOtp,
      data: {'email': email, 'code': code},
    );
    if (response.data?['success'] == true) {
      final token = response.data['token'];
      if (token != null) {
        await StorageService.saveToken(token);
      }
      final user = UserModel.fromJson(response.data['data'], token: token);
      await StorageService.saveUser(user.toJson());
      return user;
    } else {
      throw Exception(
        response.data?['message'] ?? 'Ungültiger Bestätigungscode',
      );
    }
  }

  Future<void> resetPassword({
    required String email,
    required String password,
    String? token,
  }) async {
    final data = <String, dynamic>{'email': email, 'password': password};
    if (token != null) {
      data['token'] = token;
    }
    final response = await apiClient.post(
      ApiConstants.resetPassword,
      data: data,
    );
    if (response.data?['success'] != true) {
      throw Exception(
        response.data?['message'] ?? 'Fehler beim Zurücksetzen des Passworts',
      );
    }
  }

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await apiClient.post(
      ApiConstants.changePassword,
      data: {
        'userId': userId,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    if (response.data?['success'] != true) {
      throw Exception(
        response.data?['message'] ?? 'Fehler beim Ändern des Passworts',
      );
    }
  }

  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? country,
    String? cityState,
    File? avatarFile,
    Uint8List? avatarBytes,
    String? avatarName,
  }) async {
    final map = <String, dynamic>{'userId': userId};
    if (name != null) map['name'] = name;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    if (country != null) map['country'] = country;
    if (cityState != null) map['cityState'] = cityState;

    FormData formData = FormData.fromMap(map);

    if (avatarBytes != null) {
      formData.files.add(
        MapEntry(
          'avatar',
          MultipartFile.fromBytes(
            avatarBytes,
            filename: avatarName ?? 'avatar.jpg',
          ),
        ),
      );
    } else if (avatarFile != null) {
      formData.files.add(
        MapEntry(
          'avatar',
          await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split('/').last,
          ),
        ),
      );
    }

    final response = await apiClient.put(
      ApiConstants.updateProfile,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data?['success'] == true) {
      final token = await StorageService.getToken();
      final user = UserModel.fromJson(response.data['data'], token: token);
      await StorageService.saveUser(user.toJson());
      return user;
    } else {
      throw Exception(
        response.data?['message'] ?? 'Fehler beim Aktualisieren des Profils',
      );
    }
  }

  Future<UserModel> getSingleUser(String userId) async {
    final response = await apiClient.get('${ApiConstants.singleUser}/$userId');
    if (response.data?['success'] == true) {
      final token = await StorageService.getToken();
      final user = UserModel.fromJson(response.data['data'], token: token);
      await StorageService.saveUser(user.toJson());
      return user;
    } else {
      throw Exception(response.data?['message'] ?? 'Benutzer nicht gefunden');
    }
  }
}
