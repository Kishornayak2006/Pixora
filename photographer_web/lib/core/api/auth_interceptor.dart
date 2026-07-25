import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage().getToken();

    // Debug log to verify token retrieval in console
    print("TOKEN = $token");

    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If backend returns 401 Unauthorized, clear stored invalid token
    if (err.response?.statusCode == 401) {
      print("Unauthorized (401) — clearing stored token.");
      await TokenStorage().clearToken();
    }

    return handler.next(err);
  }
}