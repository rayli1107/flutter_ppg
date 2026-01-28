import 'dart:math';

import 'package:camera/camera.dart';

class BrightnessDetectionConfig {
    final double brightnessThreshold;
    final double deviationThreshold;

    BrightnessDetectionConfig({
        this.brightnessThreshold = 0.5,
        this.deviationThreshold = 0.08,
    });
}

class BrightnessDetectionModel {
    BrightnessDetectionModel(this._config);

    final BrightnessDetectionConfig _config;

    double _currentBrightness = 1;
    double _currentDeviation = 1;
    double get currentBrightness => _currentBrightness;
    double get currentDeviation => _currentDeviation;

    (bool, double) processFrame(CameraImage image) {
        double brightness = 1;
        double deviation = 1;
        
        switch (image.format.group) {
            case ImageFormatGroup.yuv420:
                (brightness, deviation) = _getBrightnessYUV420(image);
                break;
            case ImageFormatGroup.bgra8888:
                break;
            default: 
                break;

        }

        bool isCovered = brightness < _config.brightnessThreshold &&
                         deviation < _config.deviationThreshold;

        _currentBrightness = brightness;
        _currentDeviation = deviation;

        return (isCovered, brightness);
    }


    // Returns the average brightness and the standard deviation
    (double, double) _getBrightnessYUV420(CameraImage image) {
        var planeBrightness = image.planes[0];
        double sum = 0;
        double sumSquared = 0;
        for (var y = 0; y < image.height; ++y) {
            for (var x = 0; x < image.width; ++x) {
                var index = y * planeBrightness.bytesPerRow + x;
                double value = planeBrightness.bytes[index] / 256;

                sum += value;
                sumSquared += value * value;
            }
        }

        int count = image.width * image.height;
        double brightness = sum / count;
        double deviation = sqrt(sumSquared / count - brightness * brightness);
        return (brightness, deviation);
    }
}