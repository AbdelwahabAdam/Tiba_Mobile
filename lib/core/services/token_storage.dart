import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const List<String> _keys = <String>[
    'access_token',
    'refresh_token',
    'role',
  ];

  static Future<void> save(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<String?> read(String key) => _storage.read(key: key);

  static Future<void> clear() async {
    for (final key in _keys) {
      await _storage.delete(key: key);
    }
  }
}
