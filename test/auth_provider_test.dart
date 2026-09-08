import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_krepted_flutter/core/network/api_client.dart';
import 'package:n_krepted_flutter/core/services/storage_service.dart';
import 'package:n_krepted_flutter/data/models/user_model.dart';
import 'package:n_krepted_flutter/data/repositories/auth_repository.dart';
import 'package:n_krepted_flutter/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const storedUser = <String, Object>{
    '_id': 'owner-1',
    'name': 'Restaurant Owner',
    'email': 'owner@example.com',
    'role': 'restaurant_owner',
    'isVerified': true,
  };

  test('startup clears a persisted session rejected with 401', () async {
    SharedPreferences.setMockInitialValues({
      'nk_token': 'expired-token',
      'nk_user':
          '{"_id":"owner-1","name":"Restaurant Owner",'
          '"email":"owner@example.com","role":"restaurant_owner",'
          '"isVerified":true}',
    });
    final provider = AuthProvider(
      authRepository: _RefreshAuthRepository(statusCode: 401),
    );

    await provider.initialization;

    expect(provider.isInitialized, isTrue);
    expect(provider.isAuthenticated, isFalse);
    expect(await StorageService.getToken(), isNull);
    expect(await StorageService.getUser(), isNull);
  });

  test('startup keeps the cached session during a server outage', () async {
    SharedPreferences.setMockInitialValues({
      'nk_token': 'still-potentially-valid-token',
      'nk_user':
          '{"_id":"owner-1","name":"Restaurant Owner",'
          '"email":"owner@example.com","role":"restaurant_owner",'
          '"isVerified":true}',
    });
    final provider = AuthProvider(authRepository: _RefreshAuthRepository());

    await provider.initialization;

    expect(provider.isInitialized, isTrue);
    expect(provider.isAuthenticated, isTrue);
    expect(provider.currentUser?.id, storedUser['_id']);
    expect(await StorageService.getToken(), 'still-potentially-valid-token');
  });
}

class _RefreshAuthRepository extends AuthRepository {
  final int? statusCode;

  _RefreshAuthRepository({this.statusCode}) : super(apiClient: ApiClient());

  @override
  Future<UserModel> getSingleUser(String userId) async {
    final requestOptions = RequestOptions(path: '/auth/single-user/$userId');
    throw DioException(
      requestOptions: requestOptions,
      response: statusCode == null
          ? null
          : Response<void>(
              requestOptions: requestOptions,
              statusCode: statusCode,
            ),
      type: statusCode == null
          ? DioExceptionType.connectionError
          : DioExceptionType.badResponse,
    );
  }
}
