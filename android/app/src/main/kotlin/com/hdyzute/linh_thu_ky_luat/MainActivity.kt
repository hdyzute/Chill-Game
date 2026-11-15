package com.hdyzute.linh_thu_ky_luat

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "linh_thu/system")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Trang thông tin app: nơi bật "Tự khởi chạy" và bỏ giới hạn
                    // pin trên Xiaomi và các máy tự tắt app chạy nền.
                    "openAppSettings" -> {
                        startActivity(
                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                                .setData(Uri.fromParts("package", packageName, null))
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
