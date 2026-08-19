import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../data/models/deal_model.dart';
import '../data/repositories/deal_repository.dart';

class SavedProvider with ChangeNotifier {
  final DealRepository dealRepository;

  List<String> _savedDealIds = [];
  List<DealModel> _savedDeals = [];
  bool _isLoading = false;

  SavedProvider({required this.dealRepository}) {
    loadSavedDeals();
  }

  List<String> get savedDealIds => _savedDealIds;
  List<DealModel> get savedDeals => _savedDeals;
  bool get isLoading => _isLoading;

  bool isSaved(String dealId) => _savedDealIds.contains(dealId);

  Future<void> loadSavedDeals() async {
    _isLoading = true;
    notifyListeners();

    _savedDealIds = await StorageService.getSavedDealIds();
    
    try {
      final allDeals = await dealRepository.getAllDeals(limit: 50);
      _savedDeals = allDeals.where((d) => _savedDealIds.contains(d.id)).toList();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleSave(DealModel deal) async {
    await StorageService.toggleSavedDealId(deal.id);
    _savedDealIds = await StorageService.getSavedDealIds();

    if (_savedDealIds.contains(deal.id)) {
      if (!_savedDeals.any((d) => d.id == deal.id)) {
        _savedDeals.add(deal);
      }
    } else {
      _savedDeals.removeWhere((d) => d.id == deal.id);
    }

    notifyListeners();
  }
}
