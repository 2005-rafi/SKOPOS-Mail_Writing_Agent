/// Centralized API endpoint route definitions.
/// No endpoint strings may be hardcoded inside screens or repositories.
abstract class ApiEndpoints {
  static const String health = '/health';
  static const String config = '/config';
  static const String generate = '/generate';
  static const String rewrite = '/rewrite';
  static const String refine = '/refine';
  static const String providerModels = '/provider/models';
  static const String providerUsage = '/provider/usage';
}
