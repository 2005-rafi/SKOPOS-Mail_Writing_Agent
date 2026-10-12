import 'package:flutter/material.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/backend_health_manager.dart';
import '../../../core/storage/history_storage_service.dart';
import '../../../core/storage/local_settings_store.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../compose/domain/compose_models.dart';
import '../data/rewrite_repository.dart';
import '../domain/rewrite_models.dart';

enum RewriteState { idle, rewriting, success, error }

/// Feature controller coordinating rewrite operations.
class RewriteController extends ChangeNotifier {
  RewriteController({
    required this.repository,
    required this.secureStorage,
    required this.settingsStore,
    required this.historyStorage,
    this.healthManager,
  });

  final RewriteRepository repository;
  final SecureStorageService secureStorage;
  final LocalSettingsStore settingsStore;
  final HistoryStorageService historyStorage;
  final BackendHealthManager? healthManager;

  RewriteState _state = RewriteState.idle;
  GenerateResponse? _currentOutput;
  String? _errorMessage;
  SettingsModel _settings = const SettingsModel();

  RewriteState get state => _state;
  bool get isLoading => _state == RewriteState.rewriting;
  GenerateResponse? get currentOutput => _currentOutput;
  String? get errorMessage => _errorMessage;
  SettingsModel get settings => _settings;

  void updateSettings(SettingsModel newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  Future<bool> rewrite({
    required String existingContent,
    String? instruction,
  }) async {
    final cleanContent = existingContent.trim();
    if (cleanContent.length < 5) {
      _errorMessage = 'Please provide draft content to rewrite (at least 5 characters).';
      _state = RewriteState.error;
      notifyListeners();
      return false;
    }

    final provider = await settingsStore.getActiveProvider();
    final model = await settingsStore.getSelectedModel(provider);
    String apiKey = '';

    if (provider != 'mock') {
      apiKey = await secureStorage.getApiKey(provider) ?? '';
      if (apiKey.isEmpty) {
        _errorMessage = 'Please enter your ${provider.toUpperCase()} API key in Settings.';
        _state = RewriteState.error;
        notifyListeners();
        return false;
      }
    } else {
      apiKey = 'mock-key';
    }

    _state = RewriteState.rewriting;
    _errorMessage = null;
    notifyListeners();

    final request = RewriteRequest(
      existingContent: cleanContent,
      instruction: instruction?.trim().isNotEmpty == true ? instruction!.trim() : null,
      contentType: _settings.contentType,
      settings: _settings,
      provider: provider,
      model: model,
      apiKey: apiKey,
    );

    final result = await repository.rewrite(request);

    return result.when(
      onSuccess: (response) {
        healthManager?.markHealthyManually();
        _currentOutput = response;
        _state = RewriteState.success;
        _errorMessage = null;
        final historyPayload = {
          ...response.toJson(),
          'scenario': instruction?.trim().isNotEmpty == true
              ? 'Rewrite: ${instruction!.trim()}'
              : 'Rewrite Draft',
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
        _state = RewriteState.error;
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
      return 'The AI provider timed out during rewriting. Try reducing length.';
    }
    if (err is UnauthorizedException) {
      return 'Invalid API key. Please verify your credentials in Settings.';
    }
    return err.message;
  }
}
