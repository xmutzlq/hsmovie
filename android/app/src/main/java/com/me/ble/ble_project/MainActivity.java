package com.me.ble.ble_project;

import io.flutter.embedding.android.FlutterActivity;

import android.content.res.Configuration;
import android.os.Bundle;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String PLAYER_CONTROLS_CHANNEL = "hsmovie/player_controls";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                PLAYER_CONTROLS_CHANNEL
        ).setMethodCallHandler((call, result) -> {
            WindowManager.LayoutParams attributes = getWindow().getAttributes();
            if ("getBrightness".equals(call.method)) {
                float brightness = attributes.screenBrightness;
                result.success(brightness < 0 ? 0.5 : brightness);
                return;
            }
            if ("setBrightness".equals(call.method)) {
                Double value = call.arguments();
                if (value == null) {
                    result.error("invalid_brightness", "Brightness is required", null);
                    return;
                }
                attributes.screenBrightness = (float) Math.max(0, Math.min(1, value));
                getWindow().setAttributes(attributes);
                result.success(null);
                return;
            }
            result.notImplemented();
        });
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
    }
}
