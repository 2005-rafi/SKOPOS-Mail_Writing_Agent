import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

/// Represents the connection lifecycle state of the backend service.
enum BackendHealthState {
  /// Initial undetermined status before first probe.
  unknown,

  /// Actively probing backend availability.
  checking,

  /// Cold-start detected (Render instance waking up from inactivity).
  wakingUp,

  /// Backend is responsive and healthy within the cooldown window.
  online,

  /// Backend is unreachable after retry budget exhausted.
  offline,
}

/// Orchestrator for smart backend health checks, cold-start wake-up handling,
/// and request deduplication optimized for Render.com free-tier instances.
///
/// Prevents the "thundering herd" problem and eliminates redundant polling
/// from 100+ concurrent clients through client-side caching and single-flight futures.
class BackendHealthManager extends ChangeNotifier with WidgetsBindingObserver {
  BackendHealthManager({
    required this.apiClient,
    Duration? cooldownDuration,
    this.maxWakeupAttempts = 5,
    this.enableLifecycleObserver = true,
  }) : cooldownDuration = cooldownDuration ?? const Duration(minutes: 3) {
    if (enableLifecycleObserver) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  final ApiClient apiClient;

  /// Duration for which a successful health check is considered valid without network calls.
  final Duration cooldownDuration;

  /// Maximum retry probes during a cold-start wake-up cycle.
  final int maxWakeupAttempts;

  final bool enableLifecycleObserver;

  final Random _random = Random();

  BackendHealthState _state = BackendHealthState.unknown;
  DateTime? _lastHealthyAt;
  Future<bool>? _inFlightCheck;
  int _currentWakeupAttempt = 0;

  BackendHealthState get state => _state;
  bool get isOnline => _state == BackendHealthState.online;
  bool get isWakingUp => _state == BackendHealthState.wakingUp;
  bool get isChecking => _state == BackendHealthState.checking;
  int get currentWakeupAttempt => _currentWakeupAttempt;

  /// True if a successful health check is still within its cached TTL window.
  bool get isCooldownActive {
    if (_lastHealthyAt == null || _state != BackendHealthState.online) {
      return false;
    }
    return DateTime.now().difference(_lastHealthyAt!) < cooldownDuration;
  }

  /// Observes app lifecycle state. Only initiates health verification when
  /// the user brings the app to the foreground and the cooldown window has expired.
  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) {
      if (!isCooldownActive) {
        checkOrWakeBackend();
      }
    }
  }

  /// Verifies backend health and manages progressive wake-up if sleeping.
  ///
  /// Guarantees:
  /// 1. If healthy and cooldown is active, returns `true` immediately (0 network calls).
  /// 2. If a probe is already running, joins the existing Future (single-flight deduplication).
  /// 3. If sleeping (cold-start), triggers progressive retry with randomized jitter.
  Future<bool> checkOrWakeBackend({bool force = false}) {
    if (!force && isCooldownActive) {
      return Future.value(true);
    }

    if (_inFlightCheck != null) {
      return _inFlightCheck!;
    }

    _inFlightCheck = _performHealthCheck(force: force).whenComplete(() {
      _inFlightCheck = null;
    });

    return _inFlightCheck!;
  }

  Future<bool> _performHealthCheck({required bool force}) async {
    _setState(BackendHealthState.checking);
    _currentWakeupAttempt = 0;

    // Quick initial probe (6 seconds timeout)
    final initialSuccess = await _probeHealth(timeout: const Duration(seconds: 6));
    if (initialSuccess) {
      _markAsOnline();
      return true;
    }

    // Initial probe failed or timed out: server is likely cold-starting on Render
    _setState(BackendHealthState.wakingUp);

    // Progressive backoff with jitter (e.g. 3s, 6s, 9s, 12s, 15s)
    const baseBackoffSeconds = [3, 6, 9, 12, 15];

    for (int i = 0; i < maxWakeupAttempts; i++) {
      _currentWakeupAttempt = i + 1;
      notifyListeners();

      final backoff = baseBackoffSeconds[min(i, baseBackoffSeconds.length - 1)];
      // Add 0-1000ms jitter to prevent 100+ clients from hitting Render at the exact same millisecond
      final jitterMs = _random.nextInt(1000);
      await Future<void>.delayed(Duration(seconds: backoff, milliseconds: jitterMs));

      final success = await _probeHealth(timeout: const Duration(seconds: 8));
      if (success) {
        _markAsOnline();
        return true;
      }
    }

    // Exhausted retries without response
    _setState(BackendHealthState.offline);
    return false;
  }

  /// Lightweight GET health check to verify endpoint response
  Future<bool> _probeHealth({required Duration timeout}) async {
    try {
      final result = await apiClient.get(
        ApiEndpoints.health,
        timeout: timeout,
      );
      return result.isSuccess;
    } catch (_) {
      return false;
    }
  }

  void _markAsOnline() {
    _lastHealthyAt = DateTime.now();
    _currentWakeupAttempt = 0;
    _setState(BackendHealthState.online);
  }

  /// Manually mark backend as active (called when any standard API request succeeds)
  void markHealthyManually() {
    _markAsOnline();
  }

  /// Manually mark backend as offline (called when network errors occur)
  void markOfflineManually() {
    _lastHealthyAt = null;
    _setState(BackendHealthState.offline);
  }

  void _setState(BackendHealthState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (enableLifecycleObserver) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
}
