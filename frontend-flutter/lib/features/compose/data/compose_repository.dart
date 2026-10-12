import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import '../domain/compose_models.dart';

/// Repository for triggering generation and refinement through the deployed API.
class ComposeRepository {
  ComposeRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<GenerateResponse>> generate(GenerateRequest request) async {
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
