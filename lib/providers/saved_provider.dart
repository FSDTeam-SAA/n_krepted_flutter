import 'package:flutter/material.dart';
import '../core/network/api_error.dart';
import '../data/models/deal_model.dart';
import '../data/repositories/deal_repository.dart';

class SavedEntry {
  final DealModel restaurant;
  final String? dishId;
  const SavedEntry(this.restaurant, this.dishId);
  DealDish? get dish =>
      restaurant.activeDishes.where((dish) => dish.id == dishId).firstOrNull;
}

class SavedProvider with ChangeNotifier {
  final DealRepository dealRepository;
  List<SavedEntry> entries = [];
  bool _isLoading = false, _disposed = false;
  String? _userId, errorMessage;
  int _generation = 0;
  int _accountGeneration = 0;
  final Set<String> _pending = {};
  SavedProvider({required this.dealRepository});
  List<String> get savedDealIds => entries
      .where((e) => e.dishId == null)
      .map((e) => e.restaurant.id)
      .toList();
  List<DealModel> get savedDeals => entries.map((e) => e.restaurant).toList();
  bool get isLoading => _isLoading;
  bool isPending(String id, {String? dishId}) =>
      _pending.contains('$id:${dishId ?? ''}');
  bool isSaved(String id, {String? dishId}) =>
      entries.any((e) => e.restaurant.id == id && e.dishId == dishId);
  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    ++_accountGeneration;
    ++_generation;
    entries = [];
    _pending.clear();
    errorMessage = null;
    _isLoading = false;
    Future.microtask(() {
      if (!_disposed && _userId == userId) loadSavedDeals();
    });
  }

  Future<void> loadSavedDeals() async {
    final generation = ++_generation;
    if (_userId == null) {
      entries = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final items = await dealRepository.getSavedItems();
      if (_disposed || generation != _generation) return;
      entries = items
          .map(
            (item) => SavedEntry(
              DealModel.fromJson(item['restaurant']),
              item['dishId']?.toString().isNotEmpty == true
                  ? item['dishId'].toString()
                  : null,
            ),
          )
          .toList();
    } catch (error) {
      if (generation == _generation) errorMessage = friendlyApiError(error);
    } finally {
      if (!_disposed && generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> toggleSave(DealModel deal, {String? dishId}) async {
    if (_userId == null) {
      errorMessage = 'Bitte zuerst anmelden.';
      notifyListeners();
      return false;
    }
    final key = '${deal.id}:${dishId ?? ''}';
    if (!_pending.add(key)) return false;
    final user = _userId;
    final account = _accountGeneration;
    notifyListeners();
    final saved = !isSaved(deal.id, dishId: dishId);
    try {
      await dealRepository.setSaved(deal.id, dishId: dishId, saved: saved);
      if (_disposed || user != _userId || account != _accountGeneration) {
        return false;
      }
      // A GET begun before this write completed must not overwrite the saved state.
      ++_generation;
      _isLoading = false;
      entries.removeWhere(
        (e) => e.restaurant.id == deal.id && e.dishId == dishId,
      );
      if (saved) entries.insert(0, SavedEntry(deal, dishId));
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      if (!_disposed && user == _userId && account == _accountGeneration) {
        errorMessage = friendlyApiError(error);
        notifyListeners();
      }
      return false;
    } finally {
      if (!_disposed && account == _accountGeneration) {
        _pending.remove(key);
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    super.dispose();
  }
}
