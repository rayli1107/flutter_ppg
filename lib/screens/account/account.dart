import 'package:flutter/material.dart';
import 'package:flutter_ppg/models/ppg_session.dart';
import 'package:flutter_ppg/services/ppg_session_manager.dart';

class AccountScreen extends StatefulWidget {
    const AccountScreen({super.key});

    @override
    State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
    List<MapEntry<dynamic, PPGSession>> _sessions = [];

    @override
    void initState() {
        super.initState();
        _loadSessions();
    }

    void _loadSessions() {
        setState(() {
            _sessions = PPGSessionManager.instance.getSessionsSortedByDate(descending: true);
        });
    }

    Future<void> _deleteSession(dynamic key) async {
        final confirmed = await _showDeleteConfirmDialog();
        if (confirmed == true) {
            await PPGSessionManager.instance.deleteSession(key);
            _loadSessions();
        }
    }

    Future<bool?> _showDeleteConfirmDialog() {
        return showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('確認刪除'),
                content: const Text('確定要刪除此心跳記錄嗎？'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                    ),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('刪除'),
                    ),
                ],
            ),
        );
    }

    void _showSessionDetail(MapEntry<dynamic, PPGSession> sessionEntry) {
        showDialog(
            context: context,
            builder: (context) => _SessionDetailDialog(
                sessionEntry: sessionEntry,
                onDelete: () async {
                    Navigator.pop(context);
                    await _deleteSession(sessionEntry.key);
                },
            ),
        );
    }

    String _formatDateTime(DateTime dt) {
        return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
               '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('心跳記錄'),
                centerTitle: true,
            ),
            body: _sessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                        final sessionEntry = _sessions[index];
                        final session = sessionEntry.value;
                        return _buildSessionCard(sessionEntry, session);
                    },
                ),
        );
    }

    Widget _buildEmptyState() {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                        '尚無心跳記錄',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                ],
            ),
        );
    }

    Widget _buildSessionCard(MapEntry<dynamic, PPGSession> sessionEntry, PPGSession session) {
        return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
                onTap: () => _showSessionDetail(sessionEntry),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                        children: [
                            Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFE53935).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                    Icons.favorite,
                                    color: Color(0xFFE53935),
                                    size: 24,
                                ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                            _formatDateTime(session.timestamp),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                            ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                            children: [
                                                Text(
                                                    '${session.averageHeartRate.round()}',
                                                    style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFFE53935),
                                                    ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                    'BPM',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ),
                            IconButton(
                                onPressed: () => _deleteSession(sessionEntry.key),
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red.shade400,
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}

class _SessionDetailDialog extends StatelessWidget {
    const _SessionDetailDialog({
        required this.sessionEntry,
        required this.onDelete,
    });

    final MapEntry<dynamic, PPGSession> sessionEntry;
    final VoidCallback onDelete;

    String _formatDateTime(DateTime dt) {
        return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
               '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    @override
    Widget build(BuildContext context) {
        final session = sessionEntry.value;
        
        return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                const Text(
                                    '心跳記錄詳情',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                                IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.close),
                                ),
                            ],
                        ),
                        const SizedBox(height: 24),
                        // Main heart rate display
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                                children: [
                                    const Icon(Icons.favorite, color: Colors.white, size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                        '${session.averageHeartRate.round()}',
                                        style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                        ),
                                    ),
                                    const Text(
                                        'BPM 平均',
                                        style: TextStyle(fontSize: 14, color: Colors.white70),
                                    ),
                                ],
                            ),
                        ),
                        const SizedBox(height: 20),
                        // Min/Max row
                        Row(
                            children: [
                                Expanded(
                                    child: _buildStatCard(
                                        icon: Icons.arrow_downward_rounded,
                                        label: '最低',
                                        value: session.minHeartRate.round().toString(),
                                        color: const Color(0xFF42A5F5),
                                    ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _buildStatCard(
                                        icon: Icons.arrow_upward_rounded,
                                        label: '最高',
                                        value: session.maxHeartRate.round().toString(),
                                        color: const Color(0xFFEF5350),
                                    ),
                                ),
                            ],
                        ),
                        const SizedBox(height: 20),
                        // Date/time info
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                        _formatDateTime(session.timestamp),
                                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                    ),
                                ],
                            ),
                        ),
                        const SizedBox(height: 24),
                        // Action buttons
                        Row(
                            children: [
                                Expanded(
                                    child: OutlinedButton.icon(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.arrow_back),
                                        label: const Text('返回'),
                                        style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                    ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: ElevatedButton.icon(
                                        onPressed: onDelete,
                                        icon: const Icon(Icons.delete),
                                        label: const Text('刪除'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }

    Widget _buildStatCard({
        required IconData icon,
        required String label,
        required String value,
        required Color color,
    }) {
        return Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
                children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(height: 4),
                    Text(
                        value,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                        ),
                    ),
                    Text(
                        label,
                        style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
                    ),
                ],
            ),
        );
    }
}