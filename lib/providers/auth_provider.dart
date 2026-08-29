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
  bool _isInitialized = false;
  String? _errorMessage;
  late final Future<void> _initialization;

  AuthProvider({required this.authRepository}) {
    _initialization = _loadUserFromStorage();
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  Future<void> get initialization => _initialization;

  Future<void> _loadUserFromStorage() async {
    try {
      final results = await Future.wait([
        StorageService.getUser(),
        StorageService.getToken(),
      ]);
      final userMap = results[0] as Map<String, dynamic>?;
      final token = results[1] as String?;

      if (userMap != null && token != null && token.isNotEmpty) {
        _currentUser = UserModel.fromJson(userMap, token: token);
        notifyListeners();
        await refreshCurrentUser();
      }
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> refreshCurrentUser() async {
    final user = _currentUser;
    if (user == null || user.id.isEmpty) return false;

    try {
      _currentUser = await authRepository.getSingleUser(user.id);
      notifyListeners();
      return true;
    } catch (_) {
      // Keep the locally restored session during temporary network failures.
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await authRepository.login(email: email, password: password);
      if (!user.isVerified || user.token == null || user.token!.isEmpty) {
        _currentUser = null;
        _errorMessage = 'Bitte verifizieren Sie zuerst Ihr Konto.';
        _setLoading(false);
        return false;
      }
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
      _currentUser = await authRepository.verifyOtp(email: email, code: code);
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
