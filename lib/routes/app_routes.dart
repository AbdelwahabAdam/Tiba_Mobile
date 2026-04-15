import 'package:get/get.dart';
import '../controllers/AuthGateController.dart';
import '../views/auth/auth_gate_page.dart';
import '../views/auth/login_page.dart';
import '../views/home/home_page.dart';

class Routes {
  static const GATE = '/';
  static const LOGIN = '/login';
  static const HOME = '/home';
}

class AppRoutes {
  static final pages = [
    GetPage(
      name: Routes.GATE,
      page: () => const AuthGatePage(),
      binding: BindingsBuilder(() {
        Get.put(AuthGateController(), permanent: true);
      }),
    ),
    GetPage(name: Routes.LOGIN, page: () => LoginPage()),
    GetPage(name: Routes.HOME, page: () => HomePage()),
  ];
}