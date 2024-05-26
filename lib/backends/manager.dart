import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Manager {
  static final storage = FlutterSecureStorage();
  static Future<void> saveSessionToken(String token) async {
    await storage.write(key: 'session', value: token);
  }

  static Future<String?> loadSessionToken() async {
    return await storage.read(key: 'session');
  }

  static Future<void> saveCsrfToken(String token) async {
    await storage.write(key: 'csrf', value: token);
  }

  static Future<String?> loadCsrfToken() async {
    return await storage.read(key: 'csrf');
  }
}
