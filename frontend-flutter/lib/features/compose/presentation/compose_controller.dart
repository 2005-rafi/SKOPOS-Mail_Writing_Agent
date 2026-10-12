import 'package:flutter/material.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/backend_health_manager.dart';
import '../../../core/storage/history_storage_service.dart';
import '../../../core/storage/local_settings_store.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/compose_repository.dart';
import '../domain/compose_models.dart';

enum ComposeState { idle, generating, refining, success, error }

/// Feature Controller managing generation and refinement state.
class ComposeController extends ChangeNotifier {
  ComposeController({
    required this.repository,
    required this.secureStorage,
    required this.settingsStore,
    required this.historyStorage,
    this.healthManager,
  });

  final ComposeRepository repository;
  final SecureStorageService secureStorage;
  final LocalSettingsStore settingsStore;
  final HistoryStorageService historyStorage;
  final BackendHealthManager? healthManager;

  ComposeState _state = ComposeState.idle;
  GenerateResponse? _currentOutput;
  String? _errorMessage;
  SettingsModel _settings = const SettingsModel();

  ComposeState get state => _state;
  bool get isLoading => _state == ComposeState.generating || _state == ComposeState.refining;
  GenerateResponse? get currentOutput => _currentOutput;
  String? get errorMessage => _errorMessage;
  SettingsModel get settings => _settings;

  void updateSettings(SettingsModel newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void loadFromHistory(GenerateResponse response) {
    _currentOutput = response;
    _state = ComposeState.success;
    _errorMessage = null;
    notifyListeners();
  }

  /// Generate communication from scenario
  Future<bool> generate(String scenario) async {
    final cleanScenario = scenario.trim();
    if (cleanScenario.length < 5) {
      _errorMessage = 'Please describe the situation in at least 5 characters.';
      _state = ComposeState.error;
      notifyListeners();
      return false;
    }

    final provider = await settingsStore.getActiveProvider();
    final model = await settingsStore.getSelectedModel(provider);
    String apiKey = '';

    if (provider != 'mock') {
      apiKey = await secureStorage.getApiKey(provider) ?? '';
      if (apiKey.isEmpty) {
        _errorMessage = 'Please provide your ${provider.toUpperCase()} API key in Settings.';
        _state = ComposeState.error;
        notifyListeners();
        return false;
      }
    } else {
      apiKey = 'mock-key';
    }

    _state = ComposeState.generating;
    _errorMessage = null;
    notifyListeners();

    final request = GenerateRequest(
      scenario: cleanScenario,
      contentType: _settings.contentType,
      settings: _settings,
      provider: provider,
      model: model,
      apiKey: apiKey,
    );

    final result = await repository.generate(request);

    return result.when(
      onSuccess: (response) {
        healthManager?.markHealthyManually();
        _currentOutput = response;
        _state = ComposeState.success;
        _errorMessage = null;
        final historyPayload = {
          ...response.toJson(),
          'scenario': cleanScenario,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        historyStorage.addHistoryItem(historyPayload);
        notifyListeners();
        return true;
      },

      onFailure: (err) {
        if (err is NetworkException || err is RequestTimeoutException) {
          healthManager?.markOfflineManually();
        }
        _errorMessage = _mapErrorMessage(err);
        _state = ComposeState.error;
        notifyListeners();
        return false;
      },
    );
  }

  /// Refine existing generated output conversationally
  Future<bool> refine(String instruction) async {
    if (_currentOutput == null) return false;
    final cleanInstruction = instruction.trim();
    if (cleanInstruction.length < 2) {
      _errorMessage = 'Please provide a refinement instruction.';
      _state = ComposeState.error;
      notifyListeners();
      return false;
    }

    final provider = await settingsStore.getActiveProvider();
    final model = await settingsStore.getSelectedModel(provider);
    String apiKey = '';

    if (provider != 'mock') {
      apiKey = await secureStorage.getApiKey(provider) ?? '';
      if (apiKey.isEmpty) {
        _errorMessage = 'Please provide your ${provider.toUpperCase()} API key in Settings.';
        _state = ComposeState.error;
        notifyListeners();
        return false;
      }
    } else {
      apiKey = 'mock-key';
    }

    _state = ComposeState.refining;
    _errorMessage = null;
    notifyListeners();

    final request = RefineRequest(
      previousOutput: _currentOutput!.output,
      instruction: cleanInstruction,
      contentType: _settings.contentType,
      settings: _settings,
      provider: provider,
      model: model,
      apiKey: apiKey,
    );

    final result = await repository.refine(request);

    return result.when(
      onSuccess: (response) {
        healthManager?.markHealthyManually();
        _currentOutput = response;
        _state = ComposeState.success;
        _errorMessage = null;
        final historyPayload = {
          ...response.toJson(),
          'scenario': 'Refinement: $cleanInstruction',
          'updatedAt': DateTime.now().toIso8601String(),
        };
        historyStorage.addHistoryItem(historyPayload);
        notifyListeners();
        return true;
      },

      onFailure: (err) {
        if (err is NetworkException || err is RequestTimeoutException) {
          healthManager?.markOfflineManually();
        }
        _errorMessage = _mapErrorMessage(err);
        _state = ComposeState.error;
        notifyListeners();
        return false;
      },
    );

  }

  String _mapErrorMessage(ApiException err) {
    if (err is NetworkException) {
      return 'Cannot reach the backend server. Verify your connection or URL in Settings.';
    }
    if (err is RequestTimeoutException) {
      return 'The AI provider timed out. Try reducing word count or switching to a faster model.';
    }
    if (err is UnauthorizedException) {
      return 'Invalid API key. Please check your credentials in Settings.';
    }
    if (err is RateLimitException) {
      return 'Rate limit reached on your free-tier quota. Please wait a moment.';
    }
    return err.message;
  }
}
