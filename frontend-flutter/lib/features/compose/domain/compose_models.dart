/// Domain models matching backend schemas for communication generation and refinement.
library;

class OutputContent {
  const OutputContent({
    this.subject,
    this.salutation,
    required this.body,
    this.closing,
  });

  final String? subject;
  final String? salutation;
  final String body;
  final String? closing;

  factory OutputContent.fromJson(Map<String, dynamic> json) {
    return OutputContent(
      subject: json['subject'] as String?,
      salutation: json['salutation'] as String?,
      body: json['body'] as String? ?? '',
      closing: json['closing'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'salutation': salutation,
      'body': body,
      'closing': closing,
    };
  }
}

class SettingsModel {
  const SettingsModel({
    this.tone = 'professional',
    this.customTone,
    this.language = 'English',
    this.contentType = 'email',
    this.style = 'concise',
    this.customStyle,
    this.subjectEnabled = true,
    this.salutationEnabled = true,
    this.closingEnabled = true,
    this.maxWords = 150,
    this.temperature = 0.7,
  });

  final String tone;
  final String? customTone;
  final String language;
  final String contentType;
  final String style;
  final String? customStyle;
  final bool subjectEnabled;
  final bool salutationEnabled;
  final bool closingEnabled;
  final int maxWords;
  final double temperature;

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      tone: json['tone'] as String? ?? 'professional',
      customTone: json['customTone'] as String?,
      language: json['language'] as String? ?? 'English',
      contentType: json['contentType'] as String? ?? 'email',
      style: json['style'] as String? ?? 'concise',
      customStyle: json['customStyle'] as String?,
      subjectEnabled: json['subjectEnabled'] as bool? ?? true,
      salutationEnabled: json['salutationEnabled'] as bool? ?? true,
      closingEnabled: json['closingEnabled'] as bool? ?? true,
      maxWords: json['maxWords'] as int? ?? 150,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tone': tone,
      if (customTone != null) 'customTone': customTone,
      'language': language,
      'contentType': contentType,
      'style': style,
      if (customStyle != null) 'customStyle': customStyle,
      'subjectEnabled': subjectEnabled,
      'salutationEnabled': salutationEnabled,
      'closingEnabled': closingEnabled,
      'maxWords': maxWords,
      'temperature': temperature,
    };
  }

  SettingsModel copyWith({
    String? tone,
    String? customTone,
    String? language,
    String? contentType,
    String? style,
    String? customStyle,
    bool? subjectEnabled,
    bool? salutationEnabled,
    bool? closingEnabled,
    int? maxWords,
    double? temperature,
  }) {
    return SettingsModel(
      tone: tone ?? this.tone,
      customTone: customTone ?? this.customTone,
      language: language ?? this.language,
      contentType: contentType ?? this.contentType,
      style: style ?? this.style,
      customStyle: customStyle ?? this.customStyle,
      subjectEnabled: subjectEnabled ?? this.subjectEnabled,
      salutationEnabled: salutationEnabled ?? this.salutationEnabled,
      closingEnabled: closingEnabled ?? this.closingEnabled,
      maxWords: maxWords ?? this.maxWords,
      temperature: temperature ?? this.temperature,
    );
  }
}


class ValidationSummary {
  const ValidationSummary({
    required this.passed,
    this.repaired = false,
    this.issues = const [],
  });

  final bool passed;
  final bool repaired;
  final List<String> issues;

  factory ValidationSummary.fromJson(Map<String, dynamic> json) {
    return ValidationSummary(
      passed: json['passed'] as bool? ?? true,
      repaired: json['repaired'] as bool? ?? false,
      issues: (json['issues'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passed': passed,
      'repaired': repaired,
      'issues': issues,
    };
  }
}

class GenerateRequest {
  const GenerateRequest({
    required this.scenario,
    this.contentType = 'email',
    required this.settings,
    required this.provider,
    this.model,
    required this.apiKey,
  });

  final String scenario;
  final String contentType;
  final SettingsModel settings;
  final String provider;
  final String? model;
  final String apiKey;

  Map<String, dynamic> toJson() {
    return {
      'scenario': scenario,
      'contentType': contentType,
      'settings': settings.toJson(),
      'provider': provider,
      if (model != null && model!.isNotEmpty) 'model': model,
      'apiKey': apiKey,
    };
  }
}

class GenerateResponse {
  const GenerateResponse({
    required this.id,
    required this.type,
    required this.output,
    required this.settings,
    required this.provider,
    required this.model,
    required this.wordCount,
    required this.validation,
    required this.createdAt,
  });

  final String id;
  final String type;
  final OutputContent output;
  final SettingsModel settings;
  final String provider;
  final String model;
  final int wordCount;
  final ValidationSummary validation;
  final String createdAt;

  factory GenerateResponse.fromJson(Map<String, dynamic> json) {
    return GenerateResponse(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'email',
      output: OutputContent.fromJson(json['output'] as Map<String, dynamic>? ?? {}),
      settings: SettingsModel.fromJson(json['settings'] as Map<String, dynamic>? ?? {}),
      provider: json['provider'] as String? ?? '',
      model: json['model'] as String? ?? '',
      wordCount: json['wordCount'] as int? ?? 0,
      validation: ValidationSummary.fromJson(json['validation'] as Map<String, dynamic>? ?? {}),
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'output': output.toJson(),
      'settings': settings.toJson(),
      'provider': provider,
      'model': model,
      'wordCount': wordCount,
      'validation': validation.toJson(),
      'createdAt': createdAt,
    };
  }
}

class RefineRequest {
  const RefineRequest({
    required this.previousOutput,
    required this.instruction,
    this.contentType = 'email',
    required this.settings,
    required this.provider,
    this.model,
    required this.apiKey,
  });

  final OutputContent previousOutput;
  final String instruction;
  final String contentType;
  final SettingsModel settings;
  final String provider;
  final String? model;
  final String apiKey;

  Map<String, dynamic> toJson() {
    return {
      'previousOutput': previousOutput.toJson(),
      'instruction': instruction,
      'contentType': contentType,
      'settings': settings.toJson(),
      'provider': provider,
      if (model != null && model!.isNotEmpty) 'model': model,
      'apiKey': apiKey,
    };
  }
}
