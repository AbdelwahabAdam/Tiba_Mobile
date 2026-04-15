import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../core/utils/app_logger.dart';
import '../core/validators/input_validator.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;

  Future<void> login() async {
    final emailError = InputValidator.validateEmail(email.value);
    if (emailError != null) {
      Get.snackbar('Error', emailError);
      return;
    }

    final passwordError = InputValidator.validatePassword(password.value);
    if (passwordError != null) {
      Get.snackbar('Error', passwordError);
      return;
    }

    try {
      isLoading.value = true;

      await AuthService.login(email.value, password.value);
      Get.offAllNamed(Routes.HOME);
    } on DioException catch (e) {
      appLogger.e(
        'Login request failed',
        error: e.error ?? e.message,
        stackTrace: e.stackTrace,
      );

      String message = 'Login failed. Please try again.';
      if (e.response?.statusCode == 401) {
        message = 'Invalid email or password';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        message = 'Connection timed out. Check your network.';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'Cannot connect to server.';
      }

      final uri = e.requestOptions.uri.toString();
      final debugInfo = 'Type: ${e.type.name} | URL: $uri | ${e.message ?? ''}';
      message = '$message\n$debugInfo';

      Get.snackbar('Login Failed', message);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }
}
