import 'package:hive_flutter/hive_flutter.dart';
import '../models/ppg_session.dart';
import '../models/ppg_session_adapter.dart';

/// SessionManager handles storing and retrieving PPGSession entries using Hive
class PPGSessionManager {
    static const String _boxName = 'ppg_sessions';
    static PPGSessionManager? _instance;

    Box<PPGSession>? _box;

    PPGSessionManager._();

    static void registerAdapters() {
        Hive.registerAdapter(PPGSessionAdapter());
    }

    /// Returns the singleton instance of SessionManager
    static PPGSessionManager get instance {
        _instance ??= PPGSessionManager._();
        return _instance!;
    }

    /// Initialize Hive and open the sessions box
    /// Call this once during app startup
    Future<void> initialize() async {
        _box = await Hive.openBox<PPGSession>(_boxName);
    }

    /// Ensures the box is initialized before operations
    void _ensureInitialized() {
        if (_box == null) {
            throw StateError(
                'SessionManager not initialized. Call initialize() first.');
        }
    }

    /// Add a new PPGSession to storage
    Future<int> addSession(PPGSession session) async {
        _ensureInitialized();
        return await _box!.add(session);
    }

    /// Get all stored PPGSession entries
    List<PPGSession> getAllSessions() {
        _ensureInitialized();
        return _box!.values.toList();
    }

    Map<dynamic, PPGSession> getAllSessionsMap() {
        _ensureInitialized();
        return _box!.toMap();
    }

    /// Get sessions sorted by timestamp (newest first)
    List<MapEntry<dynamic, PPGSession>> getSessionsSortedByDate({bool descending = true}) {
        Map<dynamic, PPGSession> sessionsMap = getAllSessionsMap();
        List<MapEntry<dynamic, PPGSession>> sessions = sessionsMap.entries.toList();
        sessions.sort((a, b) => descending 
            ? b.value.timestamp.compareTo(a.value.timestamp)
            : a.value.timestamp.compareTo(b.value.timestamp));
        return sessions;
    }

    /// Get a specific session by index
    PPGSession? getSessionAt(int index) {
        _ensureInitialized();
        if (index < 0 || index >= _box!.length) {
            return null;
        }
        return _box!.getAt(index);
    }

    /// Get session by key
    PPGSession? getSession(dynamic key) {
        _ensureInitialized();
        return _box!.get(key);
    }

    /// Update a session at a specific index
    Future<void> updateSessionAt(int index, PPGSession session) async {
        _ensureInitialized();
        await _box!.putAt(index, session);
  }

    /// Delete a session at a specific index
    Future<void> deleteSessionAt(int index) async {
        _ensureInitialized();
        await _box!.deleteAt(index);
    }

    /// Delete a session by key
    Future<void> deleteSession(dynamic key) async {
        _ensureInitialized();
        await _box!.delete(key);
    }

    /// Delete all sessions
    Future<void> clearAllSessions() async {
        _ensureInitialized();
        await _box!.clear();
    }

    /// Get the number of stored sessions
    int get sessionCount {
        _ensureInitialized();
        return _box!.length;
    }

    /// Check if there are any sessions stored
    bool get hasSessions {
        _ensureInitialized();
        return _box!.isNotEmpty;
    }

    /// Close the Hive box
    Future<void> close() async {
        await _box?.close();
        _box = null;
    }
}
