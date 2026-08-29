import 'package:flutter/foundation.dart';
import '../core/network/api_error.dart';
import '../data/models/check_in_model.dart';
import '../data/repositories/check_in_repository.dart';

class CheckInProvider with ChangeNotifier {
  final CheckInRepository repository;
  bool _isLoading = false;
  String? _errorMessage;
  CheckInModel? _latestCheckIn;
  List<CheckInModel> _checkIns = const [];

  CheckInProvider({required this.repository});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CheckInModel? get latestCheckIn => _latestCheckIn;
  List<CheckInModel> get checkIns => _checkIns;

  Future<void> fetchMyCheckIns() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _checkIns = await repository.getMyCheckIns();
    } catch (error) {
      _errorMessage = friendlyApiError(
        error,
        fallback: 'Ihre Check-ins konnten nicht geladen werden.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CheckInModel?> checkIn({
    required String restaurantId,
    required double latitude,
    required double longitude,
    required double accuracy,
    required int partySize,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _latestCheckIn = await repository.createCheckIn(
        restaurantId: restaurantId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        partySize: partySize,
      );
      _checkIns = [_latestCheckIn!, ..._checkIns];
      return _latestCheckIn;
    } catch (error) {
      _errorMessage = friendlyApiError(
        error,
        fallback: 'Der Check-in konnte nicht verifiziert werden.',
      );
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
