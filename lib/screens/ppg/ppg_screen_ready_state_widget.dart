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
        return Center(
            child: Column(
                spacing: 10,
                children: [
                    CameraPreviewWidget(
                        cameraController: cameraController,
                        brightnessDetectionModel: brightnessDetectionModel),
                    Text('將手指覆蓋在手機鏡頭上'),
                    PPGScreenSettingsWidget(
                        config: ppgScreenSettings,
                    ),
                ],
            )
        );
    }
}
