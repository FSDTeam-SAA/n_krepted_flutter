import 'package:flutter/material.dart';
import '../core/network/api_error.dart';
import '../data/models/deal_model.dart';
import '../data/repositories/deal_repository.dart';

class DealProvider with ChangeNotifier {
  final DealRepository dealRepository;

  List<DealModel> _deals = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String _searchQuery = '';
  String _locationQuery = '';
  double _radiusKm = 15;
  int _minimumRating = 0;
  String? _cuisine;

  DealProvider({required this.dealRepository}) {
    fetchDeals();
  }

  List<DealModel> get deals => _deals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get locationQuery => _locationQuery;
  double get radiusKm => _radiusKm;
  int get minimumRating => _minimumRating;
  String? get cuisine => _cuisine;

  List<DealModel> get filteredDeals {
    return _deals
        .where((d) {
          final searchMatches = _searchQuery.isEmpty ||
              d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.description.toLowerCase().contains(_searchQuery.toLowerCase());
          final locationMatches = _locationQuery.isEmpty ||
              d.location.city.toLowerCase().contains(_locationQuery.toLowerCase()) ||
              d.location.country.toLowerCase().contains(_locationQuery.toLowerCase()) ||
              d.location.address.toLowerCase().contains(_locationQuery.toLowerCase());
          final ratingMatches = d.rating >= _minimumRating;
          final cuisineMatches = _cuisine == null ||
              _cuisine!.isEmpty ||
              d.category?.categoryName.toLowerCase() == _cuisine!.toLowerCase();
          return searchMatches && locationMatches && ratingMatches && cuisineMatches;
        })
        .toList();
  }

  Future<void> fetchDeals({
    String? categoryId,
    String? search,
    String? location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deals = await dealRepository.getAllDeals(
        categoryId: categoryId,
        search: search,
        location: location,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = friendlyApiError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    _selectedCategory = categoryId;
    fetchDeals(categoryId: categoryId, search: _searchQuery);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> applyFilters({
    required String location,
    required double radiusKm,
    required int minimumRating,
    String? cuisine,
  }) async {
    _locationQuery = location.trim();
    _radiusKm = radiusKm;
    _minimumRating = minimumRating;
    _cuisine = cuisine;
    await fetchDeals(
      categoryId: _selectedCategory,
      search: _searchQuery,
      location: _locationQuery,
    );
  }

  Future<void> resetFilters() async {
    _locationQuery = '';
    _radiusKm = 15;
    _minimumRating = 0;
    _cuisine = null;
    await fetchDeals(categoryId: _selectedCategory, search: _searchQuery);
  }

  Future<DealModel?> getDealDetails(String id) async {
    try {
      return await dealRepository.getDealById(id);
    } catch (e) {
      return null;
    }
  }
}
