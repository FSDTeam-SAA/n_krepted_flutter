class ApiConstants {
  static String get baseUrl {
    const configured = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://n-krypted-sd-backend.onrender.com/api',
    );
    final normalized = configured.replaceFirst(RegExp(r'/+$'), '');
    if (normalized.endsWith('/api/v1')) {
      return normalized.replaceFirst(RegExp(r'/v1$'), '');
    }
    if (normalized.endsWith('/api')) return normalized;
    return '$normalized/api';
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
  static const String legalContent = '/content/legal';
}
