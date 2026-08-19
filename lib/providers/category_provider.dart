import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/repositories/deal_repository.dart';

class CategoryProvider with ChangeNotifier {
  final DealRepository dealRepository;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  CategoryProvider({required this.dealRepository}) {
    fetchCategories();
  }

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await dealRepository.getAllCategories();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
