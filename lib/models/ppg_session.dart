import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';

class PPGSessionEntry {
    final double _timeSeconds;
    final double _value;
    final double _deviation;

    PPGSessionEntry({
        required double timeSeconds,
        required double value,
        required double deviation}) :
        _timeSeconds = timeSeconds,
        _value = value,
        _deviation = deviation;

    double get timeSeconds => _timeSeconds;
    double get value => _value;
    double get deviation => _deviation;
}

class PPGSession {
    final DateTime timestamp;
    final List<double> data;
    final double averageHeartRate;
    final double maxHeartRate;
    final double minHeartRate;

    PPGSession({
        required this.timestamp,
        required this.data,
        required this.averageHeartRate,
        required this.maxHeartRate,
        required this.minHeartRate}) {}    
}

class PPGSessionContext extends ChangeNotifier {
    final int skippingFrames;
    final List<PPGSessionEntry> _entries;
    
    late DateTime _startTime;
    late DateTime lastHeartRateUpdateTime;
    late double? _minHeartRate;
    late double? _maxHeartRate;
    double? averageHeartRate;
    double? _currentHeartRate;
    late int _skippedFrames; 
    late double _currentMean;
    late double _currentM2;

    PPGSessionContext({
        required DateTime startTime,
        required this.skippingFrames}) :
        _entries = [] {
        reset(startTime);
    }

    UnmodifiableListView<PPGSessionEntry> get entries => UnmodifiableListView(_entries);
    DateTime get startTime => _startTime;
    double? get minHeartRate => _minHeartRate;
    double? get maxHeartRate => _maxHeartRate;

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

        int count = _entries.length + 1;
        double delta = value - _currentMean;
        _currentMean += delta / count;
        double delta2 = value - _currentMean;
        _currentM2 += delta * delta2;
        double variance = _currentM2 / count; 
        double stdDev = sqrt(variance);
        print("mean: $_currentMean, delta: $delta, delta2: $delta2, m2: $_currentM2, variance: $variance, stdDev $stdDev");
        PPGSessionEntry entry = PPGSessionEntry(
            timeSeconds: timeSeconds, value: value, deviation: delta / stdDev);

        _entries.add(entry);
        return entry;
    }

    void reset(DateTime timeStart) {
        _entries.clear();
        _startTime = timeStart;
        lastHeartRateUpdateTime = timeStart;
        _minHeartRate = null;
        _maxHeartRate = null;
        averageHeartRate = null;
        _currentHeartRate = null;
        _skippedFrames = 0;
        _currentMean = 0;
        _currentM2 = 0;
        notifyListeners();
    }
    
    double? get currentHeartRate => _currentHeartRate;
    set currentHeartRate(double value) {
        _currentHeartRate = value;
        _minHeartRate = _minHeartRate == null ? value : min(_minHeartRate!, value);
        _maxHeartRate = _maxHeartRate == null ? value : max(_maxHeartRate!, value);

        notifyListeners();
    }
}