import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/app_logger.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages: no UI interaction possible here
  appLogger.d('Background FCM message received: ${message.messageId}');
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static bool get _isSupportedPlatform {
    if (kIsWeb) {
      return true;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static Future<void> init() async {
    if (!_isSupportedPlatform) {
      appLogger.i('FCM is not supported on this platform; skipping setup');
      return;
    }

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        appLogger.w('FCM permission denied by user');
      }

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        try {
          final notification = message.notification;
          if (notification != null) {
            LocalNotificationService.show(
              title: notification.title ?? '',
              body: notification.body ?? '',
            );
          }
        } catch (e) {
          appLogger.e('Error handling foreground FCM message', error: e);
        }
      }, onError: (e) => appLogger.e('FCM onMessage stream error', error: e));
    } catch (e) {
      appLogger.e('FCM initialization failed', error: e);
    }
  }

  static Future<String?> getToken() async {
    if (!_isSupportedPlatform) {
      return null;
    }

    try {
      return _messaging.getToken();
    } catch (e) {
      appLogger.e('Failed to get FCM token', error: e);
      return null;
    }
  }
}
