import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  Position? position;
  bool isLoading = false;
  String? errorMessage;
  Future<bool> locate() async {
    if (isLoading) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Bitte Standortdienste aktivieren.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Standortzugriff in den App-Einstellungen erlauben.');
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Standortzugriff wurde nicht erlaubt.');
      }
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return true;
    } catch (error) {
      position = null;
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void update(Position value) {
    position = value;
    notifyListeners();
  }
}
