import 'package:flutter/material.dart';

import 'package:flutter_ppg/models/brightness_detection_model.dart';

class BrightnessDetectionConfigWidget extends StatelessWidget {
    const BrightnessDetectionConfigWidget({
        super.key,
        required this.config,
        required this.onToggleFlashlight,
    });

    final BrightnessDetectionConfig config;
    final Function(bool) onToggleFlashlight;

    @override
    Widget build(BuildContext context) {
        return Column(
            spacing: 10,
            children: [
                SwitchListTile(
                    title: const Text("閃光"),
                    value: config.toggleFlashlight,
                    onChanged: onToggleFlashlight),
            ],
        );
    }
}