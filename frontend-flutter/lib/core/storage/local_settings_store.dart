import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/compose/domain/compose_models.dart';
import '../config/app_config.dart';

/// Lightweight local preference storage for non-sensitive app settings.
class LocalSettingsStore {
  LocalSettingsStore([SharedPreferences? prefs]) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const String _keyActiveProvider = 'skopos_active_provider';
  static const String _keySelectedModelPrefix = 'skopos_model_';
  static const String _keyApiBaseUrl = 'skopos_api_base_url';
  static const String _keyEmailSettings = 'skopos_default_email_settings';
  static const String _keyLetterSettings = 'skopos_default_letter_settings';

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String> getActiveProvider() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyActiveProvider) ?? 'mock';
  }

  Future<void> setActiveProvider(String provider) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyActiveProvider, provider);
  }

  Future<String?> getSelectedModel(String provider) async {
    final prefs = await _getPrefs();
    return prefs.getString('$_keySelectedModelPrefix$provider');
  }

  Future<void> setSelectedModel(String provider, String modelId) async {
    final prefs = await _getPrefs();
    await prefs.setString('$_keySelectedModelPrefix$provider', modelId);
  }

  Future<String> getApiBaseUrl() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyApiBaseUrl) ?? AppConfig.defaultApiBaseUrl;
  }

  Future<void> setApiBaseUrl(String url) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyApiBaseUrl, url.trim());
  }

  /// Load content-type specific default writing preferences (Email vs Letter)
  Future<SettingsModel> getDefaultSettings(String contentType) async {
    final prefs = await _getPrefs();
    final key = contentType == 'letter' ? _keyLetterSettings : _keyEmailSettings;
    final jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          return SettingsModel.fromJson(decoded);
        }
      } catch (_) {}
    }
    return SettingsModel(
      contentType: contentType,
      tone: 'professional',
      style: 'concise',
      subjectEnabled: true,
      salutationEnabled: true,
      closingEnabled: true,
      maxWords: contentType == 'letter' ? 250 : 150,
    );
  }

  /// Save content-type specific default writing preferences
  Future<void> saveDefaultSettings(SettingsModel settings) async {
    final prefs = await _getPrefs();
    final key = settings.contentType == 'letter' ? _keyLetterSettings : _keyEmailSettings;
    await prefs.setString(key, jsonEncode(settings.toJson()));
  }
}

