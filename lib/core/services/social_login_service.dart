import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../network/api_client.dart';

class SocialLoginService {
  static Future<void>? _initialization;
  static Future<Map<String, dynamic>> credentials(
    String provider,
    ApiClient api,
  ) async {
    if (provider == 'google') {
      const clientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
      const serverId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
      if (serverId.isEmpty) {
        throw Exception('Diese Anmeldung ist momentan nicht verfügbar.');
      }
      await (_initialization ??= GoogleSignIn.instance.initialize(
        clientId: clientId.isEmpty ? null : clientId,
        serverClientId: serverId,
      ));
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null) throw Exception('Anmeldung fehlgeschlagen.');
      return {'provider': 'google', 'idToken': token};
    }
    const appleService = String.fromEnvironment('APPLE_SERVICE_ID');
    const appleRedirect = String.fromEnvironment('APPLE_REDIRECT_URI');
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            (appleService.isEmpty || appleRedirect.isEmpty))) {
      throw Exception('Diese Anmeldung ist momentan nicht verfügbar.');
    }
    final challenge = await api.get('/auth/social/challenge');
    final nonce = challenge.data['nonce'] as String;
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: sha256.convert(utf8.encode(nonce)).toString(),
      state: nonce,
      webAuthenticationOptions: defaultTargetPlatform == TargetPlatform.android
          ? WebAuthenticationOptions(
              clientId: appleService,
              redirectUri: Uri.parse(appleRedirect),
            )
          : null,
    );
    if (credential.identityToken == null) {
      throw Exception('Anmeldung fehlgeschlagen.');
    }
    return {
      'provider': 'apple',
      'idToken': credential.identityToken,
      'nonce': nonce,
      'name': [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().join(' '),
    };
  }
}
