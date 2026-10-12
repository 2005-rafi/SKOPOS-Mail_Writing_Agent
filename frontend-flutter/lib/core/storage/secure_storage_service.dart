import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure key-value storage for provider API keys (Keychain on iOS/macOS, KeyStore on Android, DPAPI on Windows).
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _groqKeyPrefix = 'skopos_api_key_groq';
  static const String _geminiKeyPrefix = 'skopos_api_key_gemini';

  Future<void> saveApiKey(String provider, String key) async {
    final storageKey = _getStorageKey(provider);
    await _storage.write(key: storageKey, value: key.trim());
  }

  Future<String?> getApiKey(String provider) async {
    final storageKey = _getStorageKey(provider);
    return _storage.read(key: storageKey);
  }

  Future<void> deleteApiKey(String provider) async {
    final storageKey = _getStorageKey(provider);
    await _storage.delete(key: storageKey);
  }

  String _getStorageKey(String provider) {
    switch (provider.toLowerCase()) {
      case 'groq':
        return _groqKeyPrefix;
      case 'gemini':
        return _geminiKeyPrefix;
      default:
        return 'skopos_api_key_${provider.toLowerCase()}';
    }
  }
}
