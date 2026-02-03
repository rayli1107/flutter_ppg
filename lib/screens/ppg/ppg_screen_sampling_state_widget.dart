import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter_ppg/models/graph_data.dart';
import 'package:flutter_ppg/screens/ppg/ppg_settings.dart';

class PPGScreenSamplingStateWidget extends StatelessWidget {
    const PPGScreenSamplingStateWidget({
        super.key,
        required this.graphData,
        required this.startTime,
        required this.ppgScreenSettings,
        required this.currentHeartRate,
    });

    final GraphData graphData;
    final DateTime startTime;
    final PPGScreenSettings ppgScreenSettings;
    final double? currentHeartRate;

    @override
    Widget build(BuildContext context) {
        var timeDiff = DateTime.now().difference(startTime);
        double timeSeconds = timeDiff.inMilliseconds / 1000;
        double progress = timeSeconds / ppgScreenSettings.length;

        Widget chartWidget;
        List<FlSpot> points = graphData.getPoints();
        if (points.length >= 10) {
            chartWidget = LineChart(
                LineChartData(
                    minX: graphData.minX,
                    maxX: graphData.maxX,
                    minY: graphData.minY,
                    maxY: graphData.maxY,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.blue, width: 1),
                    ),
                    lineBarsData: points.isEmpty ? [] : [
                        LineChartBarData(
                            spots: points,
                            isCurved: false,
                            color: Colors.red,
                            barWidth: 2,
                            dotData: FlDotData(show: false),
                        ),
                    ],
                ),
            );
        }
        else {
            chartWidget = Container();
        }

        var textStyle = TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red
        );

        String heartRateLabel = currentHeartRate == null ?
            '分析心跳中...' :
            '心率: ${currentHeartRate!.toStringAsFixed(1)}';

        return Center(
            child: Column(
                spacing: 10,
                children: [ 
                    SizedBox(
                        width: 400,
                        height: 150,
                        child: chartWidget
                    ),
                    Container(
                        width: 300,
                        height: 300,
                        child: Stack(
                            fit: StackFit.expand,
                            children: [
                                CircularProgressIndicator(
                                    color: Colors.green,
                                    value: progress,
                                    strokeWidth: 5
                                ),
                                Center(
                                    child: Text(heartRateLabel, style: textStyle)
                                )
                            ],
                        ),
                    )
                ]
            )
        );
    }
}
