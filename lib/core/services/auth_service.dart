import 'api_service.dart';
import 'token_storage.dart';
import 'device_id_service.dart';
import '../utils/app_logger.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final deviceId = await DeviceIdService.getOrCreateDeviceId();

    final res = await ApiService.authDio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        'device_id': deviceId,
        'device_name': _deviceName,
      },
    );

    await TokenStorage.save('access_token', res.data['access_token']);
    await TokenStorage.save('refresh_token', res.data['refresh_token']);
    await TokenStorage.save('role', res.data['user']['role']);

    return res.data;
  }

  static Future<bool> refreshToken() async {
    final refresh = await TokenStorage.read('refresh_token');
    if (refresh == null) return false;

    final deviceId = await DeviceIdService.getOrCreateDeviceId();

    appLogger.d('Attempting token refresh');

    try {
      final res = await ApiService.authDio.post(
        '/auth/refresh',
        data: {'refresh_token': refresh, 'device_id': deviceId},
      );

      await TokenStorage.save('access_token', res.data['access_token']);
      await TokenStorage.save('refresh_token', res.data['refresh_token']);

      return true;
    } catch (e) {
      appLogger.w('Token refresh failed', error: e);
      return false;
    }
  }

  static Future<bool> tryAutoLogin() async {
    final access = await TokenStorage.read('access_token');
    final refresh = await TokenStorage.read('refresh_token');

    if (access == null || refresh == null) {
      appLogger.d('No stored tokens – redirecting to login');
      return false;
    }

    return refreshToken();
  }

  static Future<bool> logoutCurrentDevice() async {
    final refresh = await TokenStorage.read('refresh_token');
    final deviceId = await DeviceIdService.getOrCreateDeviceId();

    try {
      await ApiService.dio.post(
        '/auth/logout',
        data: {
          if (refresh != null) 'refresh_token': refresh,
          'device_id': deviceId,
        },
      );
      return true;
    } catch (e) {
      appLogger.w(
        'Logout request failed; clearing local session only',
        error: e,
      );
      return false;
    } finally {
      await TokenStorage.clear();
    }
  }

  static Future<bool> logoutAllDevices() async {
    try {
      await ApiService.dio.post('/auth/logout-all');
      return true;
    } catch (e) {
      appLogger.w(
        'Logout-all request failed; clearing local session only',
        error: e,
      );
      return false;
    } finally {
      await TokenStorage.clear();
    }
  }

  static String get _deviceName => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android-admin',
    TargetPlatform.iOS => 'ios-admin',
    TargetPlatform.windows => 'windows-admin',
    TargetPlatform.macOS => 'macos-admin',
    TargetPlatform.linux => 'linux-admin',
    _ => 'unknown-admin',
  };
}
