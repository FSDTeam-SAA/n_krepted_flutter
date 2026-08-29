import 'package:flutter/material.dart';

import '../core/services/storage_service.dart';

class AppLanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('de');

  Locale get locale => _locale;
  bool get isGerman => _locale.languageCode == 'de';
  String get languageName => isGerman ? 'Deutsch' : 'English';

  AppLanguageProvider() {
    _restoreLanguage();
  }

  String text(String german, String english) => isGerman ? german : english;

  Future<void> _restoreLanguage() async {
    final languageCode = await StorageService.getLanguageCode();
    _locale = Locale(languageCode == 'en' ? 'en' : 'de');
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    final normalized = languageCode == 'en' ? 'en' : 'de';
    if (_locale.languageCode == normalized) return;
    _locale = Locale(normalized);
    notifyListeners();
    await StorageService.saveLanguageCode(normalized);
  }
}
