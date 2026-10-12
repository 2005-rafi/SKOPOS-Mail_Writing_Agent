import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_exception.dart';
import 'api_result.dart';

/// Centralized HTTP API client for communication with the Python FastAPI backend.
class ApiClient {
  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl ?? AppConfig.defaultApiBaseUrl,
        _client = httpClient ?? http.Client();

  String _baseUrl;
  final http.Client _client;

  String get baseUrl => _baseUrl;

  void updateBaseUrl(String newUrl) {
    var url = newUrl.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    _baseUrl = url;
  }

  /// Perform a GET request returning decoded JSON
  Future<ApiResult<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              ...?headers,
            },
          )
          .timeout(timeout ?? AppConfig.requestTimeout);

      return _handleResponse(response);
    } on SocketException {
      return const ApiFailure(NetworkException());
    } on TimeoutException {
      return const ApiFailure(RequestTimeoutException());
    } catch (e) {
      return ApiFailure(ApiException(message: e.toString()));
    }
  }

  /// Perform a POST request with JSON payload returning decoded JSON
  Future<ApiResult<Map<String, dynamic>>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
            body: jsonEncode(body),
          )
          .timeout(timeout ?? AppConfig.requestTimeout);

      return _handleResponse(response);
    } on SocketException {
      return const ApiFailure(NetworkException());
    } on TimeoutException {
      return const ApiFailure(RequestTimeoutException());
    } catch (e) {
      return ApiFailure(ApiException(message: e.toString()));
    }
  }

  /// Parse and validate HTTP response envelope
  ApiResult<Map<String, dynamic>> _handleResponse(http.Response response) {
    Map<String, dynamic> jsonBody = {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          jsonBody = decoded;
        }
      } catch (_) {
        // Body is not JSON
      }
    }

    // 2xx Success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiSuccess(jsonBody);
    }

    // Extract standardized error details if returned by backend ErrorEnvelope
    String errorMessage = 'Request failed with status ${response.statusCode}';
    String? errorCode;
    String? requestId;
    Map<String, dynamic>? errorDetails;

    if (jsonBody.containsKey('error') && jsonBody['error'] is Map<String, dynamic>) {
      final err = jsonBody['error'] as Map<String, dynamic>;
      errorMessage = err['message']?.toString() ?? errorMessage;
      errorCode = err['code']?.toString();
      requestId = err['requestId']?.toString();
      if (err['details'] is Map<String, dynamic>) {
        errorDetails = err['details'] as Map<String, dynamic>;
      }
    } else if (jsonBody.containsKey('detail')) {
      errorMessage = jsonBody['detail'].toString();
    }

    switch (response.statusCode) {
      case 401:
        return ApiFailure(UnauthorizedException(
          message: errorMessage,
          code: errorCode,
          requestId: requestId,
        ));
      case 403:
        return ApiFailure(ForbiddenException(
          message: errorMessage,
          code: errorCode,
          requestId: requestId,
        ));
      case 422:
        return ApiFailure(ValidationException(
          message: errorMessage,
          code: errorCode ?? 'VALIDATION_FAILED',
          requestId: requestId,
          details: errorDetails,
        ));
      case 429:
        return ApiFailure(RateLimitException(
          message: errorMessage,
          code: errorCode,
          requestId: requestId,
        ));
      case 500:
      case 502:
      case 503:
        return ApiFailure(ServerException(
          message: errorMessage,
          statusCode: response.statusCode,
          code: errorCode,
          requestId: requestId,
        ));
      default:
        return ApiFailure(ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          code: errorCode,
          requestId: requestId,
          details: errorDetails,
        ));
    }
  }

  void dispose() {
    _client.close();
  }
}
