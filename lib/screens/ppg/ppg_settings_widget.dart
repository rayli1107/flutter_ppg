import 'package:flutter/material.dart';

import 'package:flutter_ppg/screens/ppg/ppg_settings.dart';

class PPGScreenSettingsWidget extends StatelessWidget {
    const PPGScreenSettingsWidget({
        super.key,
        required this.config,
    });

    final PPGScreenSettings config;

    @override
    Widget build(BuildContext context) {
        return Column(
            spacing: 10,
            children: [
                SwitchListTile(
                    title: const Text("閃光"),
                    value: config.flashlight,
                    onChanged: (enable) => {config.flashlight = enable}),
                SegmentedButton<int>(
                    segments: const[
                        ButtonSegment<int>(
                            value: 30,
                            label: Text("30 秒")),
                        ButtonSegment<int>(
                            value: 60,
                            label: Text("一分鐘")),
                        ButtonSegment<int>(
                            value: 120,
                            label: Text("兩分鐘")),
                    ],
                    selected: {config.length},
                    onSelectionChanged: (values) {
                        config.length = values.first;
                    },
                ),
            ],
        );
    }
}