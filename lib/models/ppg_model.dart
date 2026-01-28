import 'dart:math';

class PPGModelEntry {
    final double timeSeconds;
    final double value;
    late double modifiedValue;
    late double deviation;
    late double rollingAverage;
    late int signal;

    PPGModelEntry({required this.timeSeconds, required this.value}) {
        modifiedValue = value;
        rollingAverage = value;
        deviation = 0;
        signal = 0;
    }
}

class PPGModelConfig {
    final int skipSamples;
    final int bufferSamples;
    final double bufferThreshold;
    final double influence;
    final double peakBufferTime;

    PPGModelConfig({
        this.skipSamples = 10,
        this.bufferSamples = 30,
        this.bufferThreshold = 0.5,
        this.influence = 1,
        this.peakBufferTime = 0.4,
    });
}

class PPGModel {
    PPGModel({required this.config}) {
        reset();
    }

    final PPGModelConfig config;
    double _currentSum = 0;
    double _currentSumSquared = 0;
    double _currentDeviation = 0;
    int _lastSignal = 0;
    int _skipped = 0;
    final List<PPGModelEntry> _entries = [];
    final List<double> _peakTimestamps = [];
    double _minHeartRate = double.maxFinite;
    double _maxHeartRate = double.minPositive;
    double _averageHeartRate = 0;
    double _currentHeartRate = 0;

    int get heartRate => _currentHeartRate.round();
    int get averageHeartRate => _averageHeartRate.round();
    int get minHeartRate => _minHeartRate.round();
    int get maxHeartRate => _maxHeartRate.round();
    bool get isBuffering => _entries.length < config.bufferSamples;
    
    void reset() {
        _skipped = 0;
        _entries.clear();
        _peakTimestamps.clear();

        _currentSum = 0;
        _currentSumSquared = 0;
        _currentDeviation = 0;
        _lastSignal = 0;
        _minHeartRate = double.maxFinite;
        _maxHeartRate = double.minPositive;
        _averageHeartRate = 0;
        _currentHeartRate = 0;
    }

    void _processInitialBuffer() {
        _currentSum = 0;
        _currentSumSquared = 0;
        _currentDeviation = 0;

        for (int i = 0; i < _entries.length; ++i) {
            double value = _entries[i].modifiedValue;
            _currentSum += value;
            _currentSumSquared += value * value;
        }

        double mean = _currentSum / _entries.length;

        for (int i = 0; i < _entries.length; ++i) {
            double diff = _entries[i].modifiedValue - mean;
            _currentDeviation += diff * diff;
        }
        _currentDeviation = sqrt(_currentDeviation / _entries.length);
    }

    bool _updateHeartRate() {
        final int interval = min(10, _peakTimestamps.length - 1);
        if (interval >= 5) {
            double timeDiffSeconds = 
                _peakTimestamps[_peakTimestamps.length - 1] -
                _peakTimestamps[_peakTimestamps.length - interval - 1];

            _currentHeartRate = interval * 60 / timeDiffSeconds;
            _minHeartRate = min(_minHeartRate, _currentHeartRate);
            _maxHeartRate = max(_maxHeartRate, _currentHeartRate);

            double timeDiffTotal =
                _peakTimestamps[_peakTimestamps.length - 1] -
                _peakTimestamps[0];
            final int count = _peakTimestamps.length - 1;
            _averageHeartRate = count * 60 / timeDiffTotal;

            return true;
        }
        return false;
    }

    bool _processRollingBuffer() {
        bool updatedHeartRate = false;

        var currentEntry = _entries[_entries.length - 1];
        var previousEntry = _entries[_entries.length - 2];
        var discardedEntry = _entries[
            _entries.length - config.bufferSamples - 1];

        double mean = _currentSum / config.bufferSamples;
        currentEntry.deviation = (currentEntry.value - mean) / _currentDeviation;

        // Check for outlier & peak
        if (currentEntry.deviation > config.bufferThreshold ||
            currentEntry.deviation < -1 * config.bufferThreshold) {
            currentEntry.signal = currentEntry.deviation > 0 ? 1 : -1;
            if (currentEntry.signal > 0 && _lastSignal <= 0) {
                _lastSignal = currentEntry.signal;
                _peakTimestamps.add(currentEntry.timeSeconds);
                updatedHeartRate = _updateHeartRate();
            } else if (currentEntry.signal < 0 && _lastSignal >= 0) {
                _lastSignal = currentEntry.signal;
            }

            currentEntry.modifiedValue =
                config.influence * currentEntry.value +
                (1 - config.influence) * previousEntry.modifiedValue;            
        }

        double newValue = currentEntry.modifiedValue;
        double oldValue = discardedEntry.modifiedValue;
        _currentSum += newValue - oldValue;
        _currentSumSquared += newValue * newValue - oldValue * oldValue;
        currentEntry.rollingAverage = _currentSum / config.bufferSamples;
        mean = _currentSum / config.bufferSamples;
        double variance = _currentSumSquared / config.bufferSamples - mean * mean;
        _currentDeviation = sqrt(max(0, variance));

        return updatedHeartRate;
    }

    int _findMaxIndex(int rangeStart, int rangeEnd) {
        int maxIndex = rangeStart;
        for (int i = rangeStart + 1; i <= rangeEnd; ++i) {
            if (_entries[i].modifiedValue > _entries[maxIndex].modifiedValue) {
                maxIndex = i;
            }
        }
        return maxIndex;
    }

    bool _checkForPeak() {
        int checkIndex = _entries.length - 2;
        int maxIndex = _findMaxIndex(checkIndex - 1, checkIndex + 1);
        if (maxIndex == checkIndex) {
            double peakTime = _entries[checkIndex].timeSeconds;
            if (_peakTimestamps.isEmpty) {
                _peakTimestamps.add(peakTime);
                return true;
            } else if (peakTime - _peakTimestamps.last > config.peakBufferTime) {
                _peakTimestamps.add(peakTime);
                return true;
            }
        }
        return false;
    }

    PPGModelEntry? processValue(double timeSeconds, double value) {
        if (_skipped < config.skipSamples) {
            ++_skipped;
            return null;
        }

        _entries.add(PPGModelEntry(timeSeconds: timeSeconds, value: value));

        if (_entries.length == config.bufferSamples) {
            _processInitialBuffer();
        } else if (_entries.length > config.bufferSamples) {
            _processRollingBuffer();
        }

        return _entries[_entries.length - 1];
    }
}