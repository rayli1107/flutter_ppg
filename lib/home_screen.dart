import 'package:flutter/material.dart';
import 'package:flutter_ppg/tab_types.dart';

class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key, required this.onRoute});

    final void Function(MainAppScreenTabType) onRoute;

    @override
    Widget build(BuildContext context) {
        return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                        const Color(0xFFF8BBD0),
                        const Color(0xFFFFFFFF),
                    ],
                ),
            ),
            child: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            const SizedBox(height: 40),
                            // App Title
                            Column(
                                children: [
                                    Icon(
                                        Icons.favorite,
                                        size: 80,
                                        color: const Color(0xFFE53935),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                        '心跳健康',
                                        style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE53935),
                                        ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        '監測您的心率與健康',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
                                        ),
                                    ),
                                ],
                            ),
                            const SizedBox(height: 60),
                            // Navigation Buttons
                            Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        _buildNavigationCard(
                                            context: context,
                                            title: '心跳偵測',
                                            subtitle: '使用相機測量您的心率',
                                            icon: Icons.monitor_heart,
                                            gradient: const LinearGradient(
                                                colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                                            ),
                                            onTap: () {
                                                onRoute(MainAppScreenTabType.HeartRate);
                                            },
                                        ),
                                        const SizedBox(height: 20),
                                        _buildNavigationCard(
                                            context: context,
                                            title: '呼吸練習',
                                            subtitle: '放鬆身心的呼吸指導',
                                            icon: Icons.air,
                                            gradient: const LinearGradient(
                                                colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                                            ),
                                            onTap: () {
                                                onRoute(MainAppScreenTabType.Exercise);
                                            },
                                        ),
                                        const SizedBox(height: 20),
                                        _buildNavigationCard(
                                            context: context,
                                            title: '歷史記錄',
                                            subtitle: '查看您的心跳記錄',
                                            icon: Icons.history,
                                            gradient: const LinearGradient(
                                                colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
                                            ),
                                            onTap: () {
                                                onRoute(MainAppScreenTabType.Account);
                                            },
                                        ),
                                    ],
                                ),
                            ),
                            const SizedBox(height: 20),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildNavigationCard({
        required BuildContext context,
        required String title,
        required String subtitle,
        required IconData icon,
        required Gradient gradient,
        required VoidCallback onTap,
    }) {
        return Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                            children: [
                                Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                        icon,
                                        size: 40,
                                        color: Colors.white,
                                    ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            Text(
                                                title,
                                                style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                subtitle,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white.withValues(alpha: 0.9),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 24,
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}
