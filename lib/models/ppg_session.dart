class PPGSessionEntry {
    final double _timeSeconds;
    final double _value;

    PPGSessionEntry({
        required double timeSeconds,
        required double value}) :
        _timeSeconds = timeSeconds,
        _value = value {}

    double get timeSeconds => _timeSeconds;
    double get value => _value;
}

class PPGSession {
    final DateTime _startTime;
    final List<PPGSessionEntry> _entries;
    final int _fps;
    double heartRate;

    PPGSession({
        required DateTime startTime,
        required int fps}) :
        _startTime = startTime,
        _fps = fps,
        _entries = [],
        heartRate = 0;

    DateTime get startTime => _startTime;
    List<PPGSessionEntry> get entries => _entries;
    int get fps => _fps;
    
    PPGSessionEntry addEntry(double timeSeconds, double value) {
        PPGSessionEntry entry = PPGSessionEntry(
            timeSeconds: timeSeconds, value: value);
        _entries.add(entry);
        return entry;
    }

    void clear() {
        _entries.clear();
    }
}
