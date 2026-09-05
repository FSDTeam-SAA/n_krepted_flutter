import 'package:flutter/material.dart';
import '../core/network/api_error.dart';
import '../data/models/deal_model.dart';
import '../data/repositories/owner_restaurant_repository.dart';

class OwnerRestaurantProvider with ChangeNotifier {
  final OwnerRestaurantRepository repository;

  DealModel? _restaurant;
  OwnerDashboardStats _dashboardStats = const OwnerDashboardStats();
  bool _isLoading = false;
  bool _isDashboardLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  OwnerRestaurantProvider({required this.repository});

  DealModel? get restaurant => _restaurant;
  OwnerDashboardStats get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  bool get isDashboardLoading => _isDashboardLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  bool get hasRestaurant => _restaurant != null;
  bool get isApproved => _restaurant?.isApproved ?? false;
  bool get isPending => _restaurant?.isPending ?? false;
  bool get isRejected => _restaurant?.isRejected ?? false;

  Future<bool> fetchMyRestaurant() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _restaurant = await repository.getMyRestaurant();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchDashboardStats() async {
    _isDashboardLoading = true;
    notifyListeners();
    try {
      _dashboardStats = await repository.getDashboardStats();
      _isDashboardLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _isDashboardLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshOwnerData() async {
    await Future.wait([fetchMyRestaurant(), fetchDashboardStats()]);
  }

  void clear() {
    _restaurant = null;
    _dashboardStats = const OwnerDashboardStats();
    _isLoading = false;
    _isDashboardLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submitRestaurant(Map<String, dynamic> payload) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _restaurant = await repository.submitRestaurant(payload);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resubmitRestaurant(Map<String, dynamic> payload) async {
    if (_restaurant == null) return false;
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _restaurant = await repository.resubmitRestaurant(
        _restaurant!.id,
        payload,
      );
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRestaurant(Map<String, dynamic> payload) async {
    if (_restaurant == null) return false;
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _restaurant = await repository.updateRestaurant(_restaurant!.id, payload);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addDish(Map<String, dynamic> payload) async {
    if (_restaurant == null) return false;
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _restaurant = await repository.addDish(_restaurant!.id, payload);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDish(String dishId, Map<String, dynamic> payload) async {
    if (_restaurant == null) return false;
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _restaurant = await repository.updateDish(
        _restaurant!.id,
        dishId,
        payload,
      );
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDish(String dishId) async {
    if (_restaurant == null) return false;
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _restaurant = await repository.deleteDish(_restaurant!.id, dishId);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
