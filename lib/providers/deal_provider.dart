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

  DealProvider({required this.dealRepository}) {
    fetchDeals();
  }

  List<DealModel> get deals => _deals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<DealModel> get filteredDeals {
    if (_searchQuery.isEmpty) return _deals;
    return _deals
        .where((d) =>
            d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> fetchDeals({String? categoryId, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deals = await dealRepository.getAllDeals(
        categoryId: categoryId,
        search: search,
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

  Future<DealModel?> getDealDetails(String id) async {
    try {
      return await dealRepository.getDealById(id);
    } catch (e) {
      return null;
    }
  }
}
