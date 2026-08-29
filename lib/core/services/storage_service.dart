import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'nk_token';
  static const String _userKey = 'nk_user';
  static const String _firstTimeKey = 'nk_first_time';
  static const String _savedDealsKey = 'nk_saved_deals';
  static const String _languageKey = 'nk_language';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(Map<String, dynamic> userMap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userMap));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_userKey);
    if (str != null) {
      try {
        return jsonDecode(str);
      } catch (_) {}
    }
    return null;
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  static Future<void> setFirstTimeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, false);
  }

  static Future<List<String>> getSavedDealIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedDealsKey) ?? [];
  }

  static Future<void> toggleSavedDealId(String dealId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_savedDealsKey) ?? [];
    if (list.contains(dealId)) {
      list.remove(dealId);
    } else {
      list.add(dealId);
    }
    await prefs.setStringList(_savedDealsKey, list);
  }

  static Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'de';
  }

  static Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
