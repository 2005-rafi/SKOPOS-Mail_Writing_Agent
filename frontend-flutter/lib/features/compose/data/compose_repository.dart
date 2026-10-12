import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_result.dart';
import '../domain/compose_models.dart';
import '../domain/local_agent_orchestrator.dart';

/// Repository for triggering generation and refinement through the deployed API or local on-device NPU.
class ComposeRepository {
  ComposeRepository(
    this._apiClient, {
    LocalAgentOrchestrator? localOrchestrator,
    LocalInferenceEngine? localInferenceEngine,
  })  : _localOrchestrator = localOrchestrator ?? const LocalAgentOrchestrator(),
        _localInferenceEngine = localInferenceEngine ?? MockLocalInferenceEngine();

  final ApiClient _apiClient;
  final LocalAgentOrchestrator _localOrchestrator;
  final LocalInferenceEngine _localInferenceEngine;

  Future<ApiResult<GenerateResponse>> generate(GenerateRequest request) async {
    if (request.provider == 'on_device') {
      try {
        final response = await _localOrchestrator.runPipeline(
          engine: _localInferenceEngine,
          scenario: request.scenario,
          settings: request.settings,
          modelId: request.model ?? 'on-device-npu-v1',
        );
        return ApiSuccess(response);
      } catch (e) {
        return ApiFailure(NetworkException(message: 'On-device inference failure: ${e.toString()}'));
      }
    }

    final result = await _apiClient.post(
      ApiEndpoints.generate,
      body: request.toJson(),
    );

    return result.when(
      onSuccess: (data) => ApiSuccess(GenerateResponse.fromJson(data)),
      onFailure: (err) => ApiFailure(err),
    );
  }

  Future<ApiResult<GenerateResponse>> refine(RefineRequest request) async {
    final result = await _apiClient.post(
      ApiEndpoints.refine,
      body: request.toJson(),
    );

    return result.when(
      onSuccess: (data) => ApiSuccess(GenerateResponse.fromJson(data)),
      onFailure: (err) => ApiFailure(err),
    );
  }
}
