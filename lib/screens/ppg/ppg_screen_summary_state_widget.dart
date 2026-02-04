import 'package:flutter/material.dart';

import 'package:flutter_ppg/models/ppg_session.dart';

class PPGScreenSummaryStateWidget extends StatelessWidget {
    const PPGScreenSummaryStateWidget({
        super.key,
        required this.session,
    });

    final PPGSession session;

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    // Main heart rate display
                    _buildMainHeartRateCard(),
                    const SizedBox(height: 24),
                    // Min/Max row
                    _buildMinMaxRow(),
                    const SizedBox(height: 32),
                    // Session info
                    _buildSessionInfo(),
                ],
            ),
        );
    }

    Widget _buildMainHeartRateCard() {
        return Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFE53935).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                    ),
                ],
            ),
            child: Column(
                children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    Text(
                        '${session.averageHeartRate.round()}',
                        style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                        ),
                    ),
                    const Text(
                        'BPM',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                        ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        '平均心跳',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                ],
            ),
        );
    }

    Widget _buildMinMaxRow() {
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                _buildStatCard(
                    icon: Icons.arrow_downward_rounded,
                    label: '最低',
                    value: session.minHeartRate.round().toString(),
                    color: const Color(0xFF42A5F5),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                    icon: Icons.arrow_upward_rounded,
                    label: '最高',
                    value: session.maxHeartRate.round().toString(),
                    color: const Color(0xFFEF5350),
                ),
            ],
        );
    }

    Widget _buildStatCard({
        required IconData icon,
        required String label,
        required String value,
        required Color color,
    }) {
        return Container(
            width: 140,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
                children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 8),
                    Text(
                        value,
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: color,
                        ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        label,
                        style: TextStyle(
                            fontSize: 14,
                            color: color.withValues(alpha: 0.8),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildSessionInfo() {
        return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                        _formatDateTime(session.timestamp),
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                ],
            ),
        );
    }

    String _formatDateTime(DateTime dt) {
        return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
               '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
}