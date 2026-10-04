import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n_krepted_flutter/core/network/api_client.dart';
import 'package:n_krepted_flutter/core/services/storage_service.dart';

class _LocalHttp extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'concurrent expired requests refresh once and retry with the persisted token',
    () => HttpOverrides.runWithHttpOverrides(() async {
      SharedPreferences.setMockInitialValues({
        'nk_token': 'expired',
        'nk_refresh_token': 'refresh',
      });
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var refreshes = 0;
      server.listen((request) async {
        request.response.headers.contentType = ContentType.json;
        if (request.uri.path == '/api/v1/auth/refresh-token') {
          refreshes++;
          final body =
              jsonDecode(await utf8.decoder.bind(request).join()) as Map;
          expect(body['refreshToken'], 'refresh');
          await Future<void>.delayed(const Duration(milliseconds: 100));
          request.response.write(
            jsonEncode({
              'data': {
                'accessToken': 'renewed',
                'refreshToken': 'next-refresh',
              },
            }),
          );
        } else if (request.headers.value('authorization') == 'Bearer renewed') {
          request.response.write('{"success":true}');
        } else {
          request.response.statusCode = 401;
          request.response.write('{"success":false}');
        }
        await request.response.close();
      });
      final client = ApiClient();
      client.dio.options.baseUrl = 'http://127.0.0.1:${server.port}/api';
      try {
        final results = await Future.wait([
          client.get('/first'),
          client.get('/second'),
        ]);
        expect(results.every((response) => response.statusCode == 200), isTrue);
        expect(refreshes, 1);
        expect(await StorageService.getToken(), 'renewed');
        expect(await StorageService.getRefreshToken(), 'next-refresh');
      } finally {
        client.dio.close(force: true);
        await server.close(force: true);
      }
    }, _LocalHttp()),
  );
}
