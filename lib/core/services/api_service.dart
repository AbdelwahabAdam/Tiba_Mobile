import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../middleware/auth_interceptor.dart';

class ApiService {
  static BaseOptions get _baseOptions => BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: Duration(seconds: ApiConfig.connectTimeoutSeconds),
    receiveTimeout: Duration(seconds: ApiConfig.receiveTimeoutSeconds),
  );

  /// Authenticated Dio (with interceptor)
  static final Dio dio = Dio(_baseOptions)..interceptors.add(AuthInterceptor());

  /// Raw Dio (NO interceptors) – for login & refresh
  static final Dio authDio = Dio(_baseOptions);
}
