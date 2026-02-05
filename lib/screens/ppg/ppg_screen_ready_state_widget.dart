import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

import 'package:flutter_ppg/models/brightness_detection_model.dart';
import 'package:flutter_ppg/screens/ppg/camera_preview_widget.dart';
import 'package:flutter_ppg/screens/ppg/ppg_settings.dart';
import 'package:flutter_ppg/screens/ppg/ppg_settings_widget.dart';

class PPGScreenReadyStateWidget extends StatelessWidget {
    const PPGScreenReadyStateWidget({
        super.key,
        required this.cameraController,
        required this.brightnessDetectionModel,
        required this.ppgScreenSettings,
    });

    final CameraController cameraController;
    final BrightnessDetectionModel brightnessDetectionModel;
    final PPGScreenSettings ppgScreenSettings;

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Expanded(
                    child: Stack(
                        children: [
                            // Camera preview as background
                            Positioned.fill(
                                child: CameraPreview(cameraController),
                            ),
                            // Dark overlay
                            Positioned.fill(
                                child: Container(
                                    color: Colors.black.withValues(alpha: 0.4),
                                ),
                            ),
                            // Circular progress indicator in center
                            Center(
                                child: CameraPreviewWidget(
                                    cameraController: cameraController,
                                    brightnessDetectionModel: brightnessDetectionModel,
                                ),
                            ),
                        ],
                    ),
                ),
                // Settings panel at bottom
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                            ),
                        ],
                    ),
                    child: SafeArea(
                        top: false,
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: PPGScreenSettingsWidget(
                                config: ppgScreenSettings,
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}
