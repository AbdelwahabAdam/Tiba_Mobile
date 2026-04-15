import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../config/api_config.dart';
import '../services/token_storage.dart';
import '../services/auth_service.dart';
import '../services/device_id_service.dart';
import '../utils/app_logger.dart';
import '../../routes/app_routes.dart';

class AuthInterceptor extends Interceptor {
  static bool _isRefreshing = false;
  static final List<Completer<String?>> _waiters = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.read('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';

      final deviceId = await DeviceIdService.getOrCreateDeviceId();
      options.headers['X-Device-Id'] = deviceId;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // Another request triggered a refresh – wait then retry
      final waiter = Completer<String?>();
      _waiters.add(waiter);
      try {
        final newToken = await waiter.future;
        if (newToken == null) throw Exception('Refresh failed');
        handler.resolve(await _retry(err.requestOptions, newToken));
      } catch (_) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;
    appLogger.d('Access token expired – attempting refresh');

    try {
      final refreshed = await AuthService.refreshToken();

      if (!refreshed) {
        appLogger.w('Token refresh failed – logging out');
        await _forceLogout();
        _notifyWaiters(null);
        handler.next(err);
        return;
      }

      final newToken = await TokenStorage.read('access_token');
      appLogger.d('Token refreshed – retrying original request');

      _notifyWaiters(newToken);
      handler.resolve(await _retry(err.requestOptions, newToken));
    } catch (e) {
      appLogger.e('Token refresh threw an error', error: e);
      await _forceLogout();
      _notifyWaiters(null);
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _notifyWaiters(String? token) {
    for (final c in _waiters) {
      if (token != null) {
        c.complete(token);
      } else {
        c.complete(null);
      }
    }
    _waiters.clear();
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String? token,
  ) async {
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      final deviceId = await DeviceIdService.getOrCreateDeviceId();
      options.headers['X-Device-Id'] = deviceId;
    }
    final retryDio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
    return retryDio.request(
      options.path,
      options: Options(
        method: options.method,
        headers: options.headers,
        responseType: options.responseType,
        contentType: options.contentType,
      ),
      data: options.data,
      queryParameters: options.queryParameters,
    );
  }

  Future<void> _forceLogout() async {
    await TokenStorage.clear();
    if (Get.currentRoute != Routes.LOGIN) {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
