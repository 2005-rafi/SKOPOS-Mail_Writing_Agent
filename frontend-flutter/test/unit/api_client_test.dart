import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skopos/core/network/api_client.dart';
import 'package:skopos/core/network/api_exception.dart';

void main() {
  group('ApiClient Tests', () {
    test('Successful GET returns decoded data', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/health'));
        return http.Response(jsonEncode({'status': 'ok', 'app': 'SKOPOS'}), 200);
      });

      final client = ApiClient(baseUrl: 'http://test.local', httpClient: mockClient);
      final result = await client.get('/health');

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?['status'], equals('ok'));
    });

    test('422 error maps to ValidationException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {
              'code': 'VALIDATION_FAILED',
              'message': 'Scenario is too short',
              'requestId': 'req-99',
            }
          }),
          422,
        );
      });

      final client = ApiClient(baseUrl: 'http://test.local', httpClient: mockClient);
      final result = await client.post('/generate', body: {'scenario': 'hi'});

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ValidationException>());
      expect(result.errorOrNull?.message, equals('Scenario is too short'));
      expect(result.errorOrNull?.requestId, equals('req-99'));
    });

    test('429 error maps to RateLimitException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {
              'code': 'RATE_LIMIT_EXCEEDED',
              'message': 'Free tier rate limit reached',
              'requestId': 'req-100',
            }
          }),
          429,
        );
      });

      final client = ApiClient(baseUrl: 'http://test.local', httpClient: mockClient);
      final result = await client.post('/generate', body: {'scenario': 'valid'});

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<RateLimitException>());
    });
  });
}
