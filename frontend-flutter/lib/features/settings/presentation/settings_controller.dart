import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/backend_health_manager.dart';
import '../../../core/storage/local_settings_store.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../compose/domain/compose_models.dart';

class ModelOption {
  const ModelOption({
    required this.id,
    required this.label,
    this.isFreeTierRecommended = false,
  });

  final String id;
  final String label;
  final bool isFreeTierRecommended;
}

/// Controller coordinating system configuration, credentials, and live model synchronization.
class SettingsController extends ChangeNotifier {
  SettingsController({
    required this.apiClient,
    required this.secureStorage,
    required this.settingsStore,
    BackendHealthManager? healthManager,
  })  : _healthManager = healthManager ?? BackendHealthManager(apiClient: apiClient),
        _ownsHealthManager = healthManager == null {
    _healthManager.addListener(_onHealthChanged);
    init();
  }

  final ApiClient apiClient;
  final SecureStorageService secureStorage;
  final LocalSettingsStore settingsStore;
  final BackendHealthManager _healthManager;
  final bool _ownsHealthManager;

  String _activeProvider = 'mock';
  String _selectedModel = '';
  String _groqKey = '';
  String _geminiKey = '';
  String _apiBaseUrl = AppConfig.defaultApiBaseUrl;
  bool _isSyncingModels = false;
  List<ModelOption> _availableModels = [];
  SettingsModel _defaultEmailSettings = const SettingsModel(contentType: 'email');
  SettingsModel _defaultLetterSettings = const SettingsModel(contentType: 'letter', maxWords: 250);

  String get activeProvider => _activeProvider;
  String get selectedModel => _selectedModel;
  String get groqKey => _groqKey;
  String get geminiKey => _geminiKey;
  String get apiBaseUrl => _apiBaseUrl;
  bool get isBackendConnected => _healthManager.isOnline;
  BackendHealthState get healthState => _healthManager.state;
  BackendHealthManager get healthManager => _healthManager;
  bool get isSyncingModels => _isSyncingModels;
  List<ModelOption> get availableModels => _availableModels;
  SettingsModel get defaultEmailSettings => _defaultEmailSettings;
  SettingsModel get defaultLetterSettings => _defaultLetterSettings;

  void _onHealthChanged() {
    notifyListeners();
  }

  Future<void> init() async {
    _activeProvider = await settingsStore.getActiveProvider();
    _apiBaseUrl = await settingsStore.getApiBaseUrl();
    apiClient.updateBaseUrl(_apiBaseUrl);

    _groqKey = await secureStorage.getApiKey('groq') ?? '';
    _geminiKey = await secureStorage.getApiKey('gemini') ?? '';

    _defaultEmailSettings = await settingsStore.getDefaultSettings('email');
    _defaultLetterSettings = await settingsStore.getDefaultSettings('letter');

    await checkBackendHealth();
    await fetchModelsForProvider(_activeProvider);
    notifyListeners();
  }

  Future<void> updateDefaultEmailSettings(SettingsModel settings) async {
    _defaultEmailSettings = settings.copyWith(contentType: 'email');
    await settingsStore.saveDefaultSettings(_defaultEmailSettings);
    notifyListeners();
  }

  Future<void> updateDefaultLetterSettings(SettingsModel settings) async {
    _defaultLetterSettings = settings.copyWith(contentType: 'letter');
    await settingsStore.saveDefaultSettings(_defaultLetterSettings);
    notifyListeners();
  }


  Future<bool> checkBackendHealth({bool force = false}) async {
    return _healthManager.checkOrWakeBackend(force: force);
  }


  Future<void> setActiveProvider(String provider) async {
    _activeProvider = provider;
    await settingsStore.setActiveProvider(provider);
    await fetchModelsForProvider(provider);
    notifyListeners();
  }

  Future<void> setModel(String modelId) async {
    _selectedModel = modelId;
    await settingsStore.setSelectedModel(_activeProvider, modelId);
    notifyListeners();
  }

  Future<void> saveGroqKey(String key) async {
    _groqKey = key.trim();
    if (_groqKey.isEmpty) {
      await secureStorage.deleteApiKey('groq');
    } else {
      await secureStorage.saveApiKey('groq', _groqKey);
    }
    notifyListeners();
  }

  Future<void> saveGeminiKey(String key) async {
    _geminiKey = key.trim();
    if (_geminiKey.isEmpty) {
      await secureStorage.deleteApiKey('gemini');
    } else {
      await secureStorage.saveApiKey('gemini', _geminiKey);
    }
    notifyListeners();
  }

  Future<void> saveApiBaseUrl(String url) async {
    _apiBaseUrl = url.trim();
    await settingsStore.setApiBaseUrl(_apiBaseUrl);
    apiClient.updateBaseUrl(_apiBaseUrl);
    await checkBackendHealth(force: true);
    notifyListeners();
  }

  /// Query available models from backend dynamically with API key or default free tier
  Future<void> fetchModelsForProvider(String provider) async {
    _isSyncingModels = true;
    notifyListeners();

    String apiKey = '';
    if (provider == 'groq') {
      apiKey = _groqKey;
    } else if (provider == 'gemini') {
      apiKey = _geminiKey;
    }

    try {
      final result = await apiClient.post(
        ApiEndpoints.providerModels,
        body: {
          'provider': provider,
          if (apiKey.isNotEmpty) 'apiKey': apiKey,
        },
      );

      result.when(
        onSuccess: (data) {
          _healthManager.markHealthyManually();
          final rawModels = data['models'] as List<dynamic>? ?? [];
          if (rawModels.isNotEmpty) {
            _availableModels = rawModels.map((m) {
              final map = m as Map<String, dynamic>;
              return ModelOption(
                id: map['id']?.toString() ?? '',
                label: map['label']?.toString() ?? '',
                isFreeTierRecommended: map['isFreeTierRecommended'] as bool? ?? false,
              );
            }).toList();

            final savedModel = _availableModels.firstWhere(
              (m) => m.id == data['defaultModel'],
              orElse: () => _availableModels.first,
            );
            _selectedModel = savedModel.id;
            settingsStore.setSelectedModel(provider, _selectedModel);
            return;
          }
          _fallbackToStaticModels(provider);
        },
        onFailure: (_) => _fallbackToStaticModels(provider),
      );
    } catch (_) {
      _fallbackToStaticModels(provider);
    } finally {
      _isSyncingModels = false;
      notifyListeners();
    }
  }

  void _fallbackToStaticModels(String provider) {
    final list = AppConfig.defaultModels[provider] ?? [];
    _availableModels = list
        .map((m) => ModelOption(
              id: m['id'] ?? '',
              label: m['label'] ?? '',
            ))
        .toList();
    if (_availableModels.isNotEmpty) {
      _selectedModel = _availableModels.first.id;
    }
  }

  @override
  void dispose() {
    _healthManager.removeListener(_onHealthChanged);
    if (_ownsHealthManager) {
      _healthManager.dispose();
    }
    super.dispose();
  }
}

