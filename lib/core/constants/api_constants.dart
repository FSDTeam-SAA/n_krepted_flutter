import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String updateProfile = '/auth/update-profile';
  static const String singleUser = '/auth/single-user';
  static const String deleteUser = '/auth/delete/user';

  // Deals / Restaurants Endpoints
  static const String deals = '/deals';
  static const String categories = '/categories';
  static const String ownerRestaurant = '/owner/restaurant';
  static const String adminRestaurants = '/admin/restaurants';
  static const String restaurants = '/restaurants';
  static const String dashboardStats = '/dashboard/stats';

  // Physical check-ins & reviews
  static const String checkIns = '/check-ins';
  static const String reviews = '/reviews';
}
