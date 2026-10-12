import '../../compose/domain/compose_models.dart';

/// Representation of a stored historical generation or rewrite matching PRD Section 22.
class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.provider,
    required this.model,
    required this.type,
    this.scenario,
    required this.output,
    required this.settings,
    required this.createdAt,
    this.updatedAt,
    required this.wordCount,
  });

  final String id;
  final String provider;
  final String model;
  final String type;
  final String? scenario;
  final OutputContent output;
  final SettingsModel settings;
  final String createdAt;
  final String? updatedAt;
  final int wordCount;

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String? ?? '',
      provider: json['provider'] as String? ?? 'mock',
      model: json['model'] as String? ?? '',
      type: json['type'] as String? ?? 'email',
      scenario: json['scenario'] as String?,
      output: OutputContent.fromJson(json['output'] as Map<String, dynamic>? ?? {}),
      settings: SettingsModel.fromJson(json['settings'] as Map<String, dynamic>? ?? {}),
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
      wordCount: json['wordCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'model': model,
      'type': type,
      if (scenario != null) 'scenario': scenario,
      'output': output.toJson(),
      'settings': settings.toJson(),
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'wordCount': wordCount,
    };
  }

  GenerateResponse toGenerateResponse() {
    return GenerateResponse(
      id: id,
      type: type,
      output: output,
      settings: settings,
      provider: provider,
      model: model,
      wordCount: wordCount,
      validation: const ValidationSummary(passed: true),
      createdAt: createdAt,
    );
  }
}

