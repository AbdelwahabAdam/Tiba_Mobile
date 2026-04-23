class ApiConfig {
  static const String _env = String.fromEnvironment(
    'DART_DEFINE_ENV',
    defaultValue: 'dev',
  );

  static const String _devBaseUrl = String.fromEnvironment(
    'DART_DEFINE_DEV_BASE_URL',
    defaultValue: 'http://192.168.1.27:6543',
  );

  static String get baseUrl {
    print("********************************************");
    print(_env);
    switch (_env) {
      case 'prod':
        return 'https://api.tiba.com';
      case 'staging':
        return 'https://staging-api.tiba.com';
      case 'dev':
      default:
        return _devBaseUrl;
    }
  }

  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;

  static const int defaultPageSize = 20;
  static const int maxPageSize = 1000;
}
