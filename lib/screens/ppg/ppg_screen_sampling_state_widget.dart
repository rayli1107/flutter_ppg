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
        required this.minHeartRate,
        required this.maxHeartRate,
    });

    final GraphData graphData;
    final DateTime startTime;
    final PPGScreenSettings ppgScreenSettings;
    final double? currentHeartRate;
    final double minHeartRate;
    final double maxHeartRate;

    @override
    Widget build(BuildContext context) {
        var timeDiff = DateTime.now().difference(startTime);
        double timeSeconds = timeDiff.inMilliseconds / 1000;
        double progress = timeSeconds / ppgScreenSettings.length;
        int remainingSeconds = (ppgScreenSettings.length - timeSeconds).ceil();

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
                                    Expanded(child: _buildChart()),
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
                                _buildCountdownTimer(progress, remainingSeconds),
                                const SizedBox(height: 32),
                                // Heart rate stats
                                _buildHeartRateStats(),
                            ],
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildChart() {
        List<FlSpot> points = graphData.getPoints();
        
        if (points.length < 10) {
            return const Center(
                child: Text(
                    '收集數據中...',
                    style: TextStyle(color: Colors.grey),
                ),
            );
        }

        return LineChart(
            LineChartData(
                minX: graphData.minX,
                maxX: graphData.maxX,
                minY: graphData.minY,
                maxY: graphData.maxY,
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (graphData.maxY - graphData.minY) / 4,
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

    Widget _buildCountdownTimer(double progress, int remainingSeconds) {
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

    Widget _buildHeartRateStats() {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                _buildStatCard(
                    label: '最低',
                    value: minHeartRate == double.maxFinite ? '--' : minHeartRate.round().toString(),
                    color: const Color(0xFF42A5F5),
                    icon: Icons.arrow_downward,
                ),
                _buildStatCard(
                    label: '當前',
                    value: currentHeartRate == null ? '--' : currentHeartRate!.round().toString(),
                    color: const Color(0xFFE53935),
                    icon: Icons.favorite,
                    isLarge: true,
                ),
                _buildStatCard(
                    label: '最高',
                    value: maxHeartRate == 0 ? '--' : maxHeartRate.round().toString(),
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
