import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';

class AuthService {
  Future<Response> login({
    required String username,
    required String password,
  }) async {
    return ApiClient.dio.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
  }
}