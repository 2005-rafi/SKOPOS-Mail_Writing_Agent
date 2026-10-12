import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skopos/core/network/api_client.dart';
import 'package:skopos/core/network/backend_health_manager.dart';

void main() {
  group('BackendHealthManager Tests', () {
    test('Initial state is unknown and not cooldown active', () {
      final mockClient = MockClient((_) async => http.Response('{}', 200));
      final apiClient = ApiClient(baseUrl: 'http://test.local', httpClient: mockClient);
      final manager = BackendHealthManager(
        apiClient: apiClient,
        enableLifecycleObserver: false,
      );

      expect(manager.state, equals(BackendHealthState.unknown));
      expect(manager.isOnline, isFalse);
      expect(manager.isCooldownActive, isFalse);
      manager.dispose();
    });

    test('Successful health probe transitions to online and activates cooldown', () async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        return http.Response(jsonEncode({'status': 'healthy'}), 200);
      });

      final apiClient = ApiClient(baseUrl: 'http://test.local', httpClient: mockClient);
      final manager = BackendHealthManager(
        apiClient: apiClient,
        cooldownDuration: const Duration(minutes: 3),
        enableLifecycleObserver: false,
      );

      final result = await manager.checkOrWakeBackend();

      expect(result, isTrue);
      expect(manager.isOnline, isTrue);
      expect(manager.state, equals(BackendHealthState.online));
      expect(manager.isCooldownActive, isTrue);
      expect(requestCount, equals(1));
      manager.dispose();
    });

    test('Cooldown window prevents duplicate network requests across 100+ simulated calls', () async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        return http.Response(jsonEncode({'status': 'healthy'}), 200);
      });

      final apiClient = ApiClient(baseUrl: 'http://test.local', httpClient: mockClient);
      final manager = BackendHealthManager(
        apiClient: apiClient,
        cooldownDuration: const Duration(minutes: 3),
        enableLifecycleObserver: false,
      );

      // First call reaches network
      await manager.checkOrWakeBackend();
      expect(requestCount, equals(1));

      // Simulate 50 subsequent calls from active user screens within cooldown
      for (int i = 0; i < 50; i++) {
        final res = await manager.checkOrWakeBackend();
        expect(res, isTrue);
      }

      // No new HTTP calls were made!
      expect(requestCount, equals(1));

      // Force parameter bypasses cooldown
      await manager.checkOrWakeBackend(force: true);
      expect(requestCount, equals(2));

      manager.dispose();
    });

    test('In-flight deduplication: concurrent calls join the same Future', () async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response(jsonEncode({'status': 'healthy'}), 200);
      });

      final apiClient = ApiClient(baseUrl: 'http://test.local', httpClient: mockClient);
      final manager = BackendHealthManager(
        apiClient: apiClient,
        enableLifecycleObserver: false,
      );

      // Fire 5 simultaneous calls at once before the first completes
      final futures = List.generate(5, (_) => manager.checkOrWakeBackend());
      final results = await Future.wait(futures);

      // All 5 futures complete successfully
      expect(results.every((r) => r == true), isTrue);
      // But only 1 HTTP request was dispatched
      expect(requestCount, equals(1));

      manager.dispose();
    });

    test('Manual healthy and offline marks transition states correctly', () {
      final mockClient = MockClient((_) async => http.Response('{}', 200));
      final apiClient = ApiClient(baseUrl: 'http://test.local', httpClient: mockClient);
      final manager = BackendHealthManager(
        apiClient: apiClient,
        enableLifecycleObserver: false,
      );

      manager.markHealthyManually();
      expect(manager.isOnline, isTrue);
      expect(manager.isCooldownActive, isTrue);

      manager.markOfflineManually();
      expect(manager.isOnline, isFalse);
      expect(manager.state, equals(BackendHealthState.offline));
      expect(manager.isCooldownActive, isFalse);

      manager.dispose();
    });
  });
}
