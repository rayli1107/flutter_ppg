import 'dart:collection';
import 'dart:math';

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

class PPGSessionContext {
    final int skippingFrames;
    final List<PPGSessionEntry> _entries;
    
    late DateTime _startTime;
    late DateTime lastHeartRateUpdateTime;
    late double _minHeartRate;
    late double _maxHeartRate;
    double? averageHeartRate;
    double? currentHeartRate;
    late int _skippedFrames; 

    PPGSessionContext({
        required DateTime startTime,
        required this.skippingFrames}) :
        _entries = [] {
        reset(startTime);
    }

    UnmodifiableListView<PPGSessionEntry> get entries => UnmodifiableListView(_entries);
    DateTime get startTime => _startTime;
    double get minHeartRate => _minHeartRate;
    double get maxHeartRate => _maxHeartRate;

    (List<double> data, double duration) getEntries(int? maxFrames) {
        int startIndex = maxFrames == null ? 0 : max(
            0, _entries.length - maxFrames);
        double duration =
            _entries.last.timeSeconds - _entries[startIndex].timeSeconds;
        var entries = _entries.skip(startIndex);
        return (entries.map((e) => e.value).toList(), duration);
    }

    PPGSessionEntry? addEntry(double timeSeconds, double value) {
        if (_skippedFrames < skippingFrames) {
            _skippedFrames++;
            return null;
        }

        PPGSessionEntry entry = PPGSessionEntry(
            timeSeconds: timeSeconds, value: value);
        _entries.add(entry);
        return entry;
    }

    void reset(DateTime timeStart) {
        _entries.clear();
        _startTime = timeStart;
        lastHeartRateUpdateTime = timeStart;
        _minHeartRate = double.maxFinite;
        _maxHeartRate = 0;
        averageHeartRate = null;
        currentHeartRate = null;
        _skippedFrames = 0;
    }
}