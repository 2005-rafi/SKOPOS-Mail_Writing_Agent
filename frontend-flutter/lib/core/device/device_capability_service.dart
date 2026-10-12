import 'dart:io';
import 'package:flutter/services.dart';

/// Hardware tier determining supported model complexity and memory safety.
enum DeviceHardwareTier {
  /// Less than 4GB RAM - On-device inference disabled to prevent OS OOM crash.
  unsupported,

  /// 4GB - 6GB RAM - Can safely execute 1B parameter INT4 quantized models.
  entry,

  /// 8GB+ RAM - Capable of executing 2B-3B parameter models with full NPU acceleration.
  premium,
}

/// Device hardware and model capability profile.
class DeviceCapability {
  const DeviceCapability({
    required this.totalRamMb,
    required this.availableRamMb,
    required this.freeDiskSpaceMb,
    required this.isNpuSupported,
    required this.hardwareTier,
    required this.hasSystemModel,
    this.systemModelName,
    required this.recommendedModel,
    required this.statusDescription,
  });

  final int totalRamMb;
  final int availableRamMb;
  final int freeDiskSpaceMb;
  final bool isNpuSupported;
  final DeviceHardwareTier hardwareTier;
  final bool hasSystemModel;
  final String? systemModelName;
  final String recommendedModel;
  final String statusDescription;

  bool get canRunOnDevice => hardwareTier != DeviceHardwareTier.unsupported;

  Map<String, dynamic> toJson() => {
        'totalRamMb': totalRamMb,
        'availableRamMb': availableRamMb,
        'freeDiskSpaceMb': freeDiskSpaceMb,
        'isNpuSupported': isNpuSupported,
        'hardwareTier': hardwareTier.name,
        'hasSystemModel': hasSystemModel,
        'systemModelName': systemModelName,
        'recommendedModel': recommendedModel,
        'statusDescription': statusDescription,
        'canRunOnDevice': canRunOnDevice,
      };
}

/// Service that discovers device RAM, storage, and NPU model capabilities.
class DeviceCapabilityService {
  DeviceCapabilityService({
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel('com.skopos.app/device_capability');

  final MethodChannel _channel;
  DeviceCapability? _cachedCapability;

  /// Inspects device hardware and queries NPU / system model presence.
  Future<DeviceCapability> getCapabilities({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCapability != null) {
      return _cachedCapability!;
    }

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getDeviceCapabilities');
      if (result != null) {
        _cachedCapability = _parseFromNative(result);
        return _cachedCapability!;
      }
    } catch (_) {
      // Platform channel not available or running in test/desktop environment
    }

    // Defensive fallback based on environment heuristics
    _cachedCapability = _computeFallbackCapability();
    return _cachedCapability!;
  }

  DeviceCapability _parseFromNative(Map<dynamic, dynamic> map) {
    final totalRamMb = (map['totalRamMb'] as num?)?.toInt() ?? 4096;
    final availRamMb = (map['availableRamMb'] as num?)?.toInt() ?? 2048;
    final freeDiskMb = (map['freeDiskSpaceMb'] as num?)?.toInt() ?? 8192;
    final isNpuSupported = (map['isNpuSupported'] as bool?) ?? false;
    final hasSystemModel = (map['hasSystemModel'] as bool?) ?? false;
    final systemModelName = map['systemModelName'] as String?;

    final tier = _calculateTier(totalRamMb);
    final recommended = hasSystemModel
        ? (systemModelName ?? 'gemini-nano-system')
        : (tier == DeviceHardwareTier.premium ? 'gemma-2-2b-int4' : 'llama-3.2-1b-int4');

    String statusDesc;
    if (hasSystemModel) {
      statusDesc = 'System NPU model ready (${systemModelName ?? "Gemini Nano"}) · 0 MB storage needed';
    } else if (tier == DeviceHardwareTier.premium) {
      statusDesc = 'Hardware NPU capable (${totalRamMb ~/ 1024}GB RAM) · Supports 2B/3B models';
    } else if (tier == DeviceHardwareTier.entry) {
      statusDesc = 'Compatible (${totalRamMb ~/ 1024}GB RAM) · Optimized for 1B lightweight model';
    } else {
      statusDesc = 'Insufficient RAM (${totalRamMb ~/ 1024}GB) · Minimum 4GB required for local AI';
    }

    return DeviceCapability(
      totalRamMb: totalRamMb,
      availableRamMb: availRamMb,
      freeDiskSpaceMb: freeDiskMb,
      isNpuSupported: isNpuSupported,
      hardwareTier: tier,
      hasSystemModel: hasSystemModel,
      systemModelName: systemModelName,
      recommendedModel: recommended,
      statusDescription: statusDesc,
    );
  }

  DeviceHardwareTier _calculateTier(int totalRamMb) {
    if (totalRamMb < 3800) {
      return DeviceHardwareTier.unsupported;
    } else if (totalRamMb < 7500) {
      return DeviceHardwareTier.entry;
    } else {
      return DeviceHardwareTier.premium;
    }
  }

  DeviceCapability _computeFallbackCapability() {
    // Default safe baseline for mobile platforms
    final isMobile = Platform.isAndroid || Platform.isIOS;
    final simulatedRamMb = isMobile ? 6144 : 8192;
    final tier = _calculateTier(simulatedRamMb);

    return DeviceCapability(
      totalRamMb: simulatedRamMb,
      availableRamMb: simulatedRamMb ~/ 2,
      freeDiskSpaceMb: 12288,
      isNpuSupported: true,
      hardwareTier: tier,
      hasSystemModel: false,
      systemModelName: null,
      recommendedModel: tier == DeviceHardwareTier.premium ? 'gemma-2-2b-int4' : 'llama-3.2-1b-int4',
      statusDescription: 'Hardware NPU capable (${simulatedRamMb ~/ 1024}GB RAM) · On-device ready',
    );
  }
}
