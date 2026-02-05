import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

import 'package:flutter_ppg/models/brightness_detection_model.dart';
import 'package:flutter_ppg/screens/ppg/camera_preview_widget.dart';
import 'package:flutter_ppg/screens/ppg/ppg_settings.dart';
import 'package:flutter_ppg/screens/ppg/ppg_settings_widget.dart';
import 'package:provider/provider.dart';

class PPGScreenReadyStateWidget extends StatelessWidget {
    const PPGScreenReadyStateWidget({super.key});

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Expanded(
                    child: Stack(
                        children: [
                            // Camera preview as background
                            Positioned.fill(
                                child: Consumer<CameraController>(
                                    builder: (context, controller, child) {
                                        return CameraPreview(controller);
                                    },
                                ),
                            ),
                            // Dark overlay
                            Positioned.fill(
                                child: Container(
                                    color: Colors.black.withValues(alpha: 0.4),
                                ),
                            ),
                            // Circular progress indicator in center
                            Center(
                                child: Consumer<BrightnessDetectionModel>(
                                    builder: (context, model, child) {
                                        return CameraPreviewWidget(
                                            brightnessDetectionModel: model,
                                        );
                                    },
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
                            child: Consumer<PPGScreenSettings>(
                                builder: (context, config, child) {
                                    return PPGScreenSettingsWidget(config: config);
                                },
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}
