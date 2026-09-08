import 'dart:async';
import 'package:flutter/material.dart';
import '../core/network/api_error.dart';
import '../data/models/deal_model.dart';
import '../data/repositories/deal_repository.dart';

class DealProvider with ChangeNotifier {
  final DealRepository dealRepository;
  List<DealModel> _deals = [];
  bool _isLoading = false, _disposed = false, hasMore = true;
  String? _errorMessage, _selectedCategory, _cuisine;
  String _searchQuery = '', _locationQuery = '';
  double _radiusKm = 10;
  int _minimumRating = 0, _request = 0, _page = 1;
  double? latitude, longitude;
  String sort = 'rating', availability = 'active';
  String? recommendation;
  Timer? _debounce;

  DealProvider({required this.dealRepository, bool autoLoad = true}) {
    if (autoLoad) fetchDeals();
  }
  List<DealModel> get deals => _deals;
  List<DealModel> get filteredDeals => _deals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get locationQuery => _locationQuery;
  double get radiusKm => _radiusKm;
  int get minimumRating => _minimumRating;
  String? get cuisine => _cuisine;

  Future<void> fetchDeals({
    String? categoryId,
    String? search,
    String? location,
    double? latitude,
    double? longitude,
    bool loadMore = false,
  }) async {
    if (_disposed || (loadMore && (_isLoading || !hasMore))) return;
    _debounce?.cancel();
    if (categoryId != null) _selectedCategory = categoryId;
    if (search != null) _searchQuery = search;
    if (location != null) _locationQuery = location;
    if (latitude != null && longitude != null) {
      this.latitude = latitude;
      this.longitude = longitude;
    }
    final request = ++_request;
    final page = loadMore ? _page + 1 : 1;
    _isLoading = true;
    _errorMessage = null;
    if (!loadMore) _deals = [];
    notifyListeners();
    try {
      final result = await dealRepository.getAllDeals(
        categoryId: _selectedCategory,
        search: _searchQuery,
        location: _locationQuery,
        latitude: this.latitude,
        longitude: this.longitude,
        radiusKm: _radiusKm,
        minimumRating: _minimumRating,
        cuisine: _cuisine,
        sort: sort,
        availability: availability,
        page: page,
        recommendation: recommendation,
      );
      if (_disposed || request != _request) return;
      _deals = loadMore ? [..._deals, ...result] : result;
      _page = page;
      hasMore = result.length == 20;
    } catch (error) {
      if (_disposed || request != _request) return;
      _errorMessage = friendlyApiError(error);
    } finally {
      if (!_disposed && request == _request) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void selectCategory(String? categoryId) {
    _selectedCategory = categoryId;
    fetchDeals();
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategory = categoryId;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    ++_request;
    _deals = [];
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), fetchDeals);
  }

  Future<void> applyFilters({
    required String location,
    required double radiusKm,
    required int minimumRating,
    String? cuisine,
    String? sort,
    double? latitude,
    double? longitude,
  }) async {
    _locationQuery = location.trim();
    _radiusKm = radiusKm;
    _minimumRating = minimumRating;
    _cuisine = cuisine;
    if (sort != null) this.sort = sort;
    await fetchDeals(latitude: latitude, longitude: longitude);
  }

  Future<void> resetFilters() async {
    _locationQuery = '';
    _radiusKm = 10;
    _minimumRating = 0;
    _cuisine = null;
    _selectedCategory = null;
    latitude = null;
    longitude = null;
    sort = 'rating';
    await fetchDeals();
  }

  Future<DealModel?> getDealDetails(String id) async {
    try {
      return await dealRepository.getDealById(id);
    } catch (error) {
      _errorMessage = friendlyApiError(error);
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
