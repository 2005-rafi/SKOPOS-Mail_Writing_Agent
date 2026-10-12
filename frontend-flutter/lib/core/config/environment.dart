import 'app_config.dart';

/// Environment mode and active runtime settings.
enum EnvironmentType { dev, staging, prod }

class Environment {
  const Environment._({
    required this.type,
    required this.apiBaseUrl,
  });

  final EnvironmentType type;
  final String apiBaseUrl;

  static const Environment development = Environment._(
    type: EnvironmentType.dev,
    apiBaseUrl: AppConfig.defaultApiBaseUrl,
  );

  static const Environment production = Environment._(
    type: EnvironmentType.prod,
    apiBaseUrl: AppConfig.defaultApiBaseUrl,
  );

  static Environment current = development;
}
