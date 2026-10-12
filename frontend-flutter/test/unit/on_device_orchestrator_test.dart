import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:skopos/core/device/device_capability_service.dart';
import 'package:skopos/core/network/api_client.dart';
import 'package:skopos/features/compose/data/compose_repository.dart';
import 'package:skopos/features/compose/domain/compose_models.dart';
import 'package:skopos/features/compose/domain/local_agent_orchestrator.dart';

void main() {
  group('DeviceCapabilityService Tests', () {
    test('Calculates hardware tiers and recommended models accurately', () async {
      final service = DeviceCapabilityService();
      final caps = await service.getCapabilities();

      expect(caps.totalRamMb, greaterThanOrEqualTo(4096));
      expect(caps.canRunOnDevice, isTrue);
      expect(caps.hardwareTier, isNot(equals(DeviceHardwareTier.unsupported)));
      expect(caps.recommendedModel, isNotEmpty);
      expect(caps.statusDescription, isNotEmpty);
    });

    test('DeviceCapability serializes to JSON map', () async {
      final service = DeviceCapabilityService();
      final caps = await service.getCapabilities();
      final json = caps.toJson();

      expect(json['totalRamMb'], equals(caps.totalRamMb));
      expect(json['canRunOnDevice'], equals(caps.canRunOnDevice));
      expect(json['hardwareTier'], equals(caps.hardwareTier.name));
    });
  });

  group('LocalPromptBuilder Tests', () {
    test('Builds structured prompts enclosing scenario in <user_input>', () {
      const settings = SettingsModel(
        contentType: 'email',
        tone: 'formal',
        style: 'concise',
        maxWords: 120,
        subjectEnabled: true,
        salutationEnabled: true,
        closingEnabled: true,
      );

      final prompts = LocalPromptBuilder.buildPrompts('Delay in shipment delivery', settings);

      expect(prompts['systemPrompt'], contains('You are SKOPOS'));
      expect(prompts['userPrompt'], contains('<user_input>'));
      expect(prompts['userPrompt'], contains('Delay in shipment delivery'));
      expect(prompts['userPrompt'], contains('FORMAL'));
      expect(prompts['userPrompt'], contains('CONCISE'));
      expect(prompts['userPrompt'], contains('120 words'));
    });
  });

  group('LocalValidator Tests', () {
    test('Passes valid structured output', () {
      const settings = SettingsModel(maxWords: 100);
      const output = OutputContent(
        subject: 'Meeting Reminder',
        salutation: 'Hello John,',
        body: 'Please remember our sprint retrospective tomorrow at 10 AM.',
        closing: 'Best regards,\nSarah',
      );

      final result = LocalValidator.validate(output, settings);

      expect(result.passed, isTrue);
      expect(result.issues, isEmpty);
    });

    test('Fails on empty body', () {
      const settings = SettingsModel();
      const output = OutputContent(
        subject: 'Subject',
        salutation: 'Hello,',
        body: '',
        closing: 'Regards,',
      );

      final result = LocalValidator.validate(output, settings);

      expect(result.passed, isFalse);
      expect(result.issues, contains('The communication body is empty.'));
    });

    test('Fails when word count exceeds allowed tolerance', () {
      const settings = SettingsModel(maxWords: 10);
      final longBody = List.generate(25, (i) => 'word$i').join(' ');
      final output = OutputContent(
        subject: 'Subject',
        salutation: 'Hello,',
        body: longBody,
        closing: 'Regards,',
      );

      final result = LocalValidator.validate(output, settings);

      expect(result.passed, isFalse);
      expect(result.issues.first, contains('exceeds configured maximum limit'));
    });

    test('Fails when conversational AI leakage marker is present', () {
      const settings = SettingsModel(maxWords: 100);
      const output = OutputContent(
        subject: 'Subject',
        salutation: 'Hello,',
        body: 'As an AI, I am pleased to assist you with this matter.',
        closing: 'Regards,',
      );

      final result = LocalValidator.validate(output, settings);

      expect(result.passed, isFalse);
      expect(result.issues.first, contains("conversational AI marker: 'as an ai'"));
    });
  });

  group('LocalAgentOrchestrator Tests', () {
    test('Runs full pipeline locally and returns valid GenerateResponse', () async {
      final mockEngine = MockLocalInferenceEngine(
        simulatedResponse: jsonEncode({
          'subject': 'Project Handover',
          'salutation': 'Dear Client,',
          'body': 'Here is the summary of project deliverables and documentation.',
          'closing': 'Warm regards,\nEngineering Team',
        }),
      );

      const orchestrator = LocalAgentOrchestrator();
      const settings = SettingsModel(maxWords: 150);

      final response = await orchestrator.runPipeline(
        engine: mockEngine,
        scenario: 'Handover project files to client',
        settings: settings,
        modelId: 'llama-3.2-1b-int4',
      );

      expect(response.provider, equals('on_device'));
      expect(response.model, equals('llama-3.2-1b-int4'));
      expect(response.output.subject, equals('Project Handover'));
      expect(response.output.salutation, equals('Dear Client,'));
      expect(response.output.body, contains('summary of project deliverables'));
      expect(response.output.closing, contains('Engineering Team'));
      expect(response.validation.passed, isTrue);
      expect(response.wordCount, greaterThan(0));
    });

    test('Extracts JSON embedded inside markdown code fence blocks', () async {
      final mockEngine = MockLocalInferenceEngine(
        simulatedResponse: '''
```json
{
  "subject": "System Maintenance",
  "salutation": "Dear Users,",
  "body": "Scheduled downtime will occur this Sunday from 2 AM to 4 AM UTC.",
  "closing": "Thank you,\\nSupport"
}
```
''',
      );

      const orchestrator = LocalAgentOrchestrator();
      const settings = SettingsModel();

      final response = await orchestrator.runPipeline(
        engine: mockEngine,
        scenario: 'Notice for server downtime',
        settings: settings,
        modelId: 'gemini-nano-system',
      );

      expect(response.output.subject, equals('System Maintenance'));
      expect(response.output.salutation, equals('Dear Users,'));
      expect(response.output.body, contains('Scheduled downtime'));
      expect(response.validation.passed, isTrue);
    });

    test('Sanitizes HTML and deduplicates salutation from body', () async {
      final mockEngine = MockLocalInferenceEngine(
        simulatedResponse: jsonEncode({
          'subject': 'Update',
          'salutation': 'Dear Team,',
          'body': 'Dear Team,<br><br>The release has been deployed.<br/>All tests pass.',
          'closing': 'Regards,',
        }),
      );

      const orchestrator = LocalAgentOrchestrator();
      const settings = SettingsModel();

      final response = await orchestrator.runPipeline(
        engine: mockEngine,
        scenario: 'Deploy announcement',
        settings: settings,
        modelId: 'gemma-2-2b-int4',
      );

      expect(response.output.salutation, equals('Dear Team,'));
      // Salutation should be deduplicated from body and HTML tags converted to clean newlines
      expect(response.output.body.startsWith('Dear Team,'), isFalse);
      expect(response.output.body, contains('The release has been deployed.'));
      expect(response.output.body, isNot(contains('<br>')));
      expect(response.output.body, isNot(contains('<br/>')));
    });
  });

  group('ComposeRepository On-Device Integration Tests', () {
    test('Delegates to local orchestrator and returns ApiSuccess when provider is on_device', () async {
      final mockEngine = MockLocalInferenceEngine();
      final repo = ComposeRepository(
        ApiClient(baseUrl: 'http://localhost:8000'),
        localInferenceEngine: mockEngine,
      );

      const request = GenerateRequest(
        scenario: 'Draft team notice',
        settings: SettingsModel(),
        provider: 'on_device',
        model: 'gemini-nano-system',
        apiKey: 'unused-on-device',
      );

      final result = await repo.generate(request);

      expect(result.isSuccess, isTrue);
      final response = result.dataOrNull!;
      expect(response.provider, equals('on_device'));
      expect(response.model, equals('gemini-nano-system'));
      expect(response.output.body, isNotEmpty);
      expect(response.validation.passed, isTrue);
    });
  });
}

