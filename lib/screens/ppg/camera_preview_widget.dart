import 'dart:math';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

import 'package:flutter_ppg/models/brightness_detection_model.dart';

class CameraPreviewWidget extends StatelessWidget {
    const CameraPreviewWidget({
        super.key,
        required this.cameraController,
        required this.brightnessDetectionModel,
    });

    final CameraController cameraController;
    final BrightnessDetectionModel brightnessDetectionModel;

    @override
    Widget build(BuildContext context) {
        final progress = _getCoverProgress();
        final percentage = (progress * 100).round();
        final isCovered = progress >= 0.95;
        
        return SizedBox(
            width: 240,
            height: 240,
            child: Stack(
                alignment: Alignment.center,
                children: [
                    // Circular progress indicator
                    SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                isCovered ? Colors.green : Colors.orange,
                            ),
                        ),
                    ),
                    // Center content
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Icon(
                                isCovered ? Icons.check_circle : Icons.fingerprint,
                                size: 60,
                                color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                                '$percentage%',
                                style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                isCovered ? '準備就緒' : '請覆蓋鏡頭',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                ),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }

    double _getCoverProgress() {
        if (brightnessDetectionModel.currentDetectionResult == null) {
            return 0;
        }

        var result = brightnessDetectionModel.currentDetectionResult!;
        double start = result.config.deviationDefaultThreshold;
        double end = 0.15;
        double value = result.deviation;
        double progress = (value - start) / (end - start);
        return 1 - max(0, min(1, progress));
    }
}
