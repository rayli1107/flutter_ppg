import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ppg/models/test_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class PPGChart extends StatelessWidget {
    const PPGChart({super.key, required this.windowSize});

    final double windowSize;

    @override
    Widget build(BuildContext context) {
        return Consumer<TestData>(
            builder: (context, data, child) {
                var minX = data.points[data.points.length - 1].x - windowSize;
                minX = max(minX, 0);
                var filteredPoints = data.points.skipWhile((p) => p.x < minX).toList();
                return Center(
                    child: SizedBox(
                        width: 400,
                        height: 200,
                        child: LineChart(
                            LineChartData(
                                minX: minX,
                                maxX: minX + windowSize,
                                minY: -1,
                                maxY: 1,
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.black, width: 1),
                                ),
                                lineBarsData: [
                                    LineChartBarData(
                                        spots: filteredPoints,
                                        isCurved: true,
                                        color: Colors.blue,
                                        barWidth: 2,
                                        dotData: FlDotData(show: false),
                                    ),
                                ],
                            ),
                        ),
                    ),
                );
            },
        );
    }
}