import 'package:flutter/material.dart';
import '../core/network/api_error.dart';
import '../data/models/deal_model.dart';
import '../data/repositories/owner_restaurant_repository.dart';

class OwnerRestaurantProvider with ChangeNotifier {
  final OwnerRestaurantRepository repository;

  DealModel? _restaurant;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  OwnerRestaurantProvider({required this.repository});

  DealModel? get restaurant => _restaurant;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  bool get hasRestaurant => _restaurant != null;
  bool get isApproved => _restaurant?.isApproved ?? false;
  bool get isPending => _restaurant?.isPending ?? false;
  bool get isRejected => _restaurant?.isRejected ?? false;

  Future<void> fetchMyRestaurant() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _restaurant = await repository.getMyRestaurant();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _isLoading = false;
      notifyListeners();
    }
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
      _restaurant = await repository.resubmitRestaurant(_restaurant!.id, payload);
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
      _restaurant = await repository.updateDish(_restaurant!.id, dishId, payload);
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
