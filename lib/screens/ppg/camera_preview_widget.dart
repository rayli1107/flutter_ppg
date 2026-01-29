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
        return Container(
            height: 400,
            child: Stack(
                alignment: AlignmentGeometry.center,
                children: [
                    CameraPreview(cameraController),
                    CircularProgressIndicator(
                        color: Colors.green,
                        value: _getCoverProgress(),
                    ),
                ],
            )
        );
    }

    double _getCoverProgress() {
        if (brightnessDetectionModel.currentDetectionResult == null) {
            return 0;
        }

        var result = brightnessDetectionModel.currentDetectionResult!;
        double start = result.config.deviationThreshold;
        double end = 0.15;
        double value = result.deviation;
        double progress = (value - start) / (end - start);
        return 1 - max(0, min(1, progress));
    }
}