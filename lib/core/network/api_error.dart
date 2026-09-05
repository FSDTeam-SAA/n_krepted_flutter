import 'dart:io';
import 'package:dio/dio.dart';

/// Turns whatever an API call threw into one short German sentence fit to put
/// in front of a user.
///
/// `DioException.toString()` is a multi-paragraph diagnostic — status code,
/// `validateStatus` explanation and a link to MDN. That was being pushed
/// straight into the sign-up error banner. The server already sends a usable
/// `message` field, so prefer it and fall back to something plain.
String friendlyApiError(
  Object error, {
  String fallback = 'Etwas ist schiefgelaufen. Bitte versuchen Sie es erneut.',
}) {
  if (error is DioException) {
    final data = error.response?.data;

    // Our API answers { success: false, message: "..." }.
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) return message.trim();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Zeitüberschreitung der Verbindung. Bitte versuchen Sie es erneut.';
      case DioExceptionType.connectionError:
        return 'Keine Verbindung zum Server. Bitte prüfen Sie Ihre Internetverbindung.';
      case DioExceptionType.cancel:
        return 'Die Anfrage wurde abgebrochen.';
      case DioExceptionType.badCertificate:
        return 'Die Serververbindung ist nicht sicher.';
      default:
        if (error.error is SocketException) {
          return 'Keine Verbindung zum Server. Bitte prüfen Sie Ihre Internetverbindung.';
        }
        return fallback;
    }
  }

  if (error is SocketException) {
    return 'Keine Verbindung zum Server. Bitte prüfen Sie Ihre Internetverbindung.';
  }

  // Plain `throw Exception('...')` from the repositories.
  final text = error.toString().replaceFirst('Exception:', '').trim();
  if (text.isEmpty || text.length > 160 || text.startsWith('DioException')) {
    return fallback;
  }
  return text;
}
