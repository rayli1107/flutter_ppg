import 'dart:math';

import 'package:camera/camera.dart';

class BrightnessDetectionConfig {
    final double brightnessThreshold;
    final double deviationThreshold;

    BrightnessDetectionConfig({
        this.brightnessThreshold = 0.5,
        this.deviationThreshold = 0.04,
    });
}

class BrightnessDetectionResult {
    BrightnessDetectionResult({
        required this.config,
        required this.brightness,
        required this.deviation,
        required this.minValueX,
        required this.minValueY,
        required this.imageAspectRatio,
    });

    final BrightnessDetectionConfig config;
    final double brightness;
    final double deviation;
    final double minValueX;
    final double minValueY;
    final double imageAspectRatio;

    bool get isCovered =>
        brightness < config.brightnessThreshold &&
        deviation < config.deviationThreshold;
}

class BrightnessDetectionModel {
    BrightnessDetectionModel(this._config);

    final BrightnessDetectionConfig _config;
    BrightnessDetectionResult? currentDetectionResult;

    BrightnessDetectionResult? processFrame(CameraImage image) {
        switch (image.format.group) {
            case ImageFormatGroup.yuv420:
                currentDetectionResult = _getBrightnessYUV420(image);
                break;
            case ImageFormatGroup.bgra8888:
                break;
            default: 
                break;

        }
        return currentDetectionResult;
    }


    // Returns the average brightness and the standard deviation
    BrightnessDetectionResult _getBrightnessYUV420(CameraImage image) {
        var planeBrightness = image.planes[0];
        double sum = 0;
        double sumSquared = 0;

        int minValueX = 0;
        int minValueY = 0;
        double curMinValue = double.maxFinite;

        for (var y = 0; y < image.height; ++y) {
            for (var x = 0; x < image.width; ++x) {
                var index = y * planeBrightness.bytesPerRow + x;
                double value = planeBrightness.bytes[index] / 256;

                if (value < curMinValue) {
                    curMinValue = value;
                    minValueX = x;
                    minValueY = y;
                }

                sum += value;
                sumSquared += value * value;
            }
        }

        int count = image.width * image.height;
        double brightness = sum / count;
        double deviation = sqrt(sumSquared / count - brightness * brightness);
        return BrightnessDetectionResult(
            config: _config,
            brightness: brightness,
            deviation: deviation,
            minValueX: minValueX / image.width,
            minValueY: minValueY / image.height,
            imageAspectRatio: image.width / image.height,
        );
    }
}