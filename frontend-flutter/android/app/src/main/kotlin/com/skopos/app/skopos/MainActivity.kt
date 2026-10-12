package com.skopos.app.skopos

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.skopos.app/device_capability"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceCapabilities" -> {
                    try {
                        val actManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val memInfo = ActivityManager.MemoryInfo()
                        actManager.getMemoryInfo(memInfo)

                        val totalRamMb = (memInfo.totalMem / (1024 * 1024)).toInt()
                        val availRamMb = (memInfo.availMem / (1024 * 1024)).toInt()

                        val stat = StatFs(filesDir.absolutePath)
                        val freeDiskSpaceMb = ((stat.availableBlocksLong * stat.blockSizeLong) / (1024 * 1024)).toInt()

                        // Check for Google AICore (Gemini Nano) system package
                        var hasSystemModel = false
                        var systemModelName: String? = null
                        try {
                            packageManager.getPackageInfo("com.google.android.aicore", 0)
                            hasSystemModel = true
                            systemModelName = "Gemini Nano"
                        } catch (_: Exception) {
                            // AICore not pre-installed or enabled on this OEM
                        }

                        // Check if Android 14+ with NPU hardware features
                        val isNpuSupported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE || hasSystemModel

                        val data = mapOf(
                            "totalRamMb" to totalRamMb,
                            "availableRamMb" to availRamMb,
                            "freeDiskSpaceMb" to freeDiskSpaceMb,
                            "isNpuSupported" to isNpuSupported,
                            "hasSystemModel" to hasSystemModel,
                            "systemModelName" to systemModelName
                        )
                        result.success(data)
                    } catch (e: Exception) {
                        result.error("CAPABILITY_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
