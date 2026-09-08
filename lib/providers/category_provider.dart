import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/repositories/deal_repository.dart';
import '../core/network/api_error.dart';

class CategoryProvider with ChangeNotifier {
  final DealRepository dealRepository;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? errorMessage;
  List<String> cities = [], cuisines = [];

  CategoryProvider({required this.dealRepository}) {
    fetchCategories();
  }

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _categories = await dealRepository.getAllCategories();
      final options = await dealRepository.getDiscoveryOptions();
      cities = (options['cities'] as List).cast<String>();
      cuisines = (options['cuisines'] as List).cast<String>();
    } catch (error) {
      errorMessage = friendlyApiError(error);
    }

    _isLoading = false;
    notifyListeners();
  }
}
