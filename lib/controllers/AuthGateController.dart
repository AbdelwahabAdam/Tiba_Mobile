import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../core/utils/app_logger.dart';
import '../routes/app_routes.dart';

class AuthGateController extends GetxController {
  bool _navigated = false;

  @override
  void onReady() {
    super.onReady();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (_navigated) return;

    try {
      final success = await AuthService.tryAutoLogin().timeout(
        const Duration(seconds: 5),
      );

      _navigated = true;

      if (success) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      _navigated = true;
      appLogger.e('Auth gate error', error: e);
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
