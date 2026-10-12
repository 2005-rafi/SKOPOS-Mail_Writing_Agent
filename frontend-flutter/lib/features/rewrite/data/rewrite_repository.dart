import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import '../../compose/domain/compose_models.dart';
import '../domain/rewrite_models.dart';

/// Repository handling rewrite API interactions.
class RewriteRepository {
  RewriteRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<GenerateResponse>> rewrite(RewriteRequest request) async {
    final result = await _apiClient.post(
      ApiEndpoints.rewrite,
      body: request.toJson(),
    );

    return result.when(
      onSuccess: (data) => ApiSuccess(GenerateResponse.fromJson(data)),
      onFailure: (err) => ApiFailure(err),
    );
  }
}
