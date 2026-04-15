import 'package:uuid/uuid.dart';

import 'token_storage.dart';

class DeviceIdService {
  static const String _deviceIdKey = 'device_id';
  static const Uuid _uuid = Uuid();

  static Future<String> getOrCreateDeviceId() async {
    final existing = await TokenStorage.read(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = _uuid.v4();
    await TokenStorage.save(_deviceIdKey, generated);
    return generated;
  }
}
