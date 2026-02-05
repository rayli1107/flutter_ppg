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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                    '設定',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                const SizedBox(height: 16),
                // Flashlight toggle
                Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: const Row(
                            children: [
                                Icon(Icons.flashlight_on, size: 20),
                                SizedBox(width: 8),
                                Text('閃光燈'),
                            ],
                        ),
                        value: config.flashlight,
                        onChanged: (enable) => {config.flashlight = enable},
                    ),
                ),
                const SizedBox(height: 16),
                // Duration selection
                const Text(
                    '測量時長',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                    ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<int>(
                        segments: const [
                            ButtonSegment<int>(
                                value: 30,
                                label: Text('30秒'),
                                icon: Icon(Icons.timer, size: 18),
                            ),
                            ButtonSegment<int>(
                                value: 60,
                                label: Text('1分鐘'),
                                icon: Icon(Icons.timer, size: 18),
                            ),
                            ButtonSegment<int>(
                                value: 120,
                                label: Text('2分鐘'),
                                icon: Icon(Icons.timer, size: 18),
                            ),
                        ],
                        selected: {config.length},
                        onSelectionChanged: (values) {
                            config.length = values.first;
                        },
                        style: ButtonStyle(
                            visualDensity: VisualDensity.comfortable,
                        ),
                    ),
                ),
            ],
        );
    }
}