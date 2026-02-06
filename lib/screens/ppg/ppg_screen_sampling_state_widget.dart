import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter_ppg/models/graph_data.dart';
import 'package:flutter_ppg/models/ppg_session.dart';
import 'package:flutter_ppg/screens/ppg/ppg_settings.dart';
import 'package:provider/provider.dart';

class CountdownTimerWidget extends StatefulWidget {
    const CountdownTimerWidget({
        super.key,
        required this.startTime,
        required this.length,
    });

    final DateTime startTime;
    final int length;

    @override
    State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
    late Timer _timer;

    @override
    void initState() {
        super.initState();

        _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
            setState(() {});
        });
    }

    @override
    void dispose() {
        super.dispose();
        _timer.cancel();
    }

    @override
    Widget build(BuildContext context) {
        var timeDiff = DateTime.now().difference(widget.startTime);
        double timeSeconds = timeDiff.inMilliseconds / 1000;
        double progress = timeSeconds / widget.length;
        int remainingSeconds = (widget.length - timeSeconds).ceil();

        return SizedBox(
            width: 180,
            height: 180,
            child: Stack(
                alignment: Alignment.center,
                children: [
                    SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4CAF50),
                            ),
                        ),
                    ),
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Text(
                                '$remainingSeconds',
                                style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50),
                                ),
                            ),
                            const Text(
                                '秒',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                ),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }
}

class PPGScreenSamplingStateWidget extends StatelessWidget {
    const PPGScreenSamplingStateWidget({
        super.key,
        required this.cameraFps,
        required this.startTime,
        required this.ppgScreenSettings
    });

    final int cameraFps;
    final DateTime startTime;
    final PPGScreenSettings ppgScreenSettings;

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                // Chart at top
                Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                    ),
                                ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    const Text(
                                        'PPG 波形',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                        ),
                                    ),
                                    const SizedBox(height: 12),
                                    Consumer<GraphData>(
                                        builder: (context, graphData, child) {
                                            return Expanded(child: _buildChart(graphData));
                                        },
                                    ),
                                ],
                            ),
                        ),
                    ),
                ),
                // Stats and timer at bottom
                Expanded(
                    flex: 3,
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                // Circular countdown timer
                                CountdownTimerWidget(
                                    startTime: startTime,
                                    length: ppgScreenSettings.length,
                                ),
                                const SizedBox(height: 32),
                                // Heart rate stats
                                Consumer<PPGSessionContext>(
                                    builder: (context, sessionContext, child) {
                                        return _buildHeartRateStats(sessionContext);
                                    },
                                ),
                            ],
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildChart(GraphData graphData) {
        if (!graphData.isReady) {
            return const Center(
                child: Text(
                    '收集數據中...',
                    style: TextStyle(color: Colors.grey),
                ),
            );
        }

        List<FlSpot> points = graphData.getPoints();
        /*
        List<double> data = points.map((e) => e.y).toList();
        data = FFT.bandpassFilter(data, cameraFps / graphData.selectEveryN);
        double minY = data.reduce(min);
        double maxY = data.reduce(max);
        if (minY * -1 > maxY) {
            maxY = minY * -1;
        } else {
            minY = maxY * -1;
        }

        List<FlSpot> processedPoints = [];
        for (int i = 0; i < points.length; ++i) {
            processedPoints.add(FlSpot(points[i].x, data[i]));
        }
        */
        return LineChart(
            LineChartData(
                minX: graphData.minX,
                maxX: graphData.maxX,
                minY: -2,
                maxY: 2,
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.2,
                    getDrawingHorizontalLine: (value) {
                        return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                        );
                    },
                ),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(
                    show: true,
                    border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                        left: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                ),
                lineBarsData: [
                    LineChartBarData(
                        spots: points,
                        isCurved: true,
                        color: const Color(0xFFE53935),
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFFE53935).withValues(alpha: 0.1),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildHeartRateStats(PPGSessionContext sessionContext) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                _buildStatCard(
                    label: '最低',
                    value: sessionContext.minHeartRate == null ? '--' :
                        sessionContext.minHeartRate!.round().toString(),
                    color: const Color(0xFF42A5F5),
                    icon: Icons.arrow_downward,
                ),
                _buildStatCard(
                    label: '當前',
                    value: sessionContext.currentHeartRate == null ? '--' :
                        sessionContext.currentHeartRate!.round().toString(),
                    color: const Color(0xFFE53935),
                    icon: Icons.favorite,
                    isLarge: true,
                ),
                _buildStatCard(
                    label: '最高',
                    value: sessionContext.maxHeartRate == null ? '--' :
                        sessionContext.maxHeartRate!.round().toString(),
                    color: const Color(0xFFEF5350),
                    icon: Icons.arrow_upward,
                ),
            ],
        );
    }

    Widget _buildStatCard({
        required String label,
        required String value,
        required Color color,
        required IconData icon,
        bool isLarge = false,
    }) {
        return Container(
            width: isLarge ? 110 : 90,
            padding: EdgeInsets.symmetric(
                vertical: isLarge ? 20 : 16,
                horizontal: 12,
            ),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1.5,
                ),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(icon, color: color, size: isLarge ? 28 : 20),
                    const SizedBox(height: 4),
                    Text(
                        value,
                        style: TextStyle(
                            fontSize: isLarge ? 32 : 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                        ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                        label,
                        style: TextStyle(
                            fontSize: 12,
                            color: color.withValues(alpha: 0.8),
                        ),
                    ),
                ],
            ),
        );
    }
}
