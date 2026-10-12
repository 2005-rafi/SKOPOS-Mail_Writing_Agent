/// Application configuration parameters and defaults.
abstract class AppConfig {
  static const String appName = 'SKOPOS';
  static const String appTagline = 'Goal-Oriented AI Writing Client';
  static const String version = '1.0.0';

  // Network defaults
  static const String productionApiBaseUrl = 'https://skopos-backend-uzfu.onrender.com/api/v1';
  static const String defaultApiBaseUrl = productionApiBaseUrl;
  static const Duration requestTimeout = Duration(seconds: 45);
  static const Duration connectTimeout = Duration(seconds: 15);

  // Content configuration defaults
  static const int defaultMaxWords = 150;
  static const int absoluteMaxWords = 500;
  static const int absoluteMinWords = 20;

  // Supported values
  static const List<String> supportedProviders = ['groq', 'gemini', 'mock'];
  static const List<String> supportedContentTypes = ['email', 'letter'];
  static const List<String> supportedTones = [
    'professional',
    'polite',
    'firm',
    'friendly',
    'apologetic',
    'persuasive',
    'custom',
  ];
  static const List<String> supportedStyles = [
    'concise',
    'detailed',
    'formal',
    'casual',
    'custom',
  ];
  static const List<String> supportedLanguages = ['English', 'Spanish', 'French', 'German'];


  // Default fallback models
  static const Map<String, List<Map<String, String>>> defaultModels = {
    'groq': [
      {'id': 'llama-3.3-70b-versatile', 'label': 'Llama 3.3 70B (Versatile)'},
      {'id': 'llama-3.1-8b-instant', 'label': 'Llama 3.1 8B (Fast)'},
      {'id': 'mixtral-8x7b-32768', 'label': 'Mixtral 8x7B (Balanced)'},
    ],
    'gemini': [
      {'id': 'gemini-1.5-flash', 'label': 'Gemini 1.5 Flash (Free Tier)'},
      {'id': 'gemini-1.5-pro', 'label': 'Gemini 1.5 Pro'},
      {'id': 'gemini-2.0-flash', 'label': 'Gemini 2.0 Flash'},
    ],
    'mock': [
      {'id': 'mock-deterministic', 'label': 'Mock Deterministic Generator'},
    ],
  };
}
