import 'dart:io';
import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../data/models/user_model.dart';
import '../core/network/api_error.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({required this.authRepository}) {
    _loadUserFromStorage();
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadUserFromStorage() async {
    final userMap = await StorageService.getUser();
    if (userMap != null) {
      final token = await StorageService.getToken();
      _currentUser = UserModel.fromJson(userMap, token: token);
      notifyListeners();

      // Refresh in background
      try {
        if (_currentUser?.id != null) {
          final refreshed = await authRepository.getSingleUser(
            _currentUser!.id,
          );
          _currentUser = refreshed;
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await authRepository.login(email: email, password: password);
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password, {
    String? phoneNumber,
    bool isRestaurantOwner = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await authRepository.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        isRestaurantOwner: isRestaurantOwner,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await authRepository.forgotPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String code) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await authRepository.verifyOtp(email: email, code: code);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String password, {
    String? token,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await authRepository.resetPassword(
        email: email,
        password: password,
        token: token,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _errorMessage = null;

    try {
      await authRepository.changePassword(
        userId: _currentUser!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? country,
    String? cityState,
    File? avatarFile,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedUser = await authRepository.updateProfile(
        userId: _currentUser!.id,
        name: name,
        phoneNumber: phoneNumber,
        country: country,
        cityState: cityState,
        avatarFile: avatarFile,
      );
      _currentUser = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAuth();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
