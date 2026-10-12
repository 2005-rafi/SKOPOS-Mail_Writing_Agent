import '../../compose/domain/compose_models.dart';

/// Request model for the rewrite endpoint.
class RewriteRequest {
  const RewriteRequest({
    required this.existingContent,
    this.instruction,
    this.contentType = 'email',
    required this.settings,
    required this.provider,
    this.model,
    required this.apiKey,
  });

  final String existingContent;
  final String? instruction;
  final String contentType;
  final SettingsModel settings;
  final String provider;
  final String? model;
  final String apiKey;

  Map<String, dynamic> toJson() {
    return {
      'existingContent': existingContent,
      if (instruction != null && instruction!.isNotEmpty) 'instruction': instruction,
      'contentType': contentType,
      'settings': settings.toJson(),
      'provider': provider,
      if (model != null && model!.isNotEmpty) 'model': model,
      'apiKey': apiKey,
    };
  }
}
