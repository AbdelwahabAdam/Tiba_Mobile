import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'core/services/fcm_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler – catches uncaught Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    appLogger.e(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  await GetStorage.init();
  await LocalNotificationService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FCMService.init();

  runApp(const MyApp());
}
