import 'dart:collection';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

final class PointEntry extends LinkedListEntry<PointEntry> {
    final FlSpot point;
    PointEntry(double x, double y) : point = FlSpot(x, y);
}

class GraphData extends ChangeNotifier {
    GraphData({
        required this.minWindowSizeSeconds,
        required this.maxWindowSizeSeconds,
        required this.skipFirst,
        this.selectEveryN = 5
    });

    final double minWindowSizeSeconds;
    final double maxWindowSizeSeconds;
    final int skipFirst;
    final int selectEveryN;
    final LinkedList<PointEntry> _points = LinkedList<PointEntry>();

    double _minY = 0;
    double _maxY = 0;
    int _skipped = 0;
    int _index = 0;

    double get minX => _points.first.point.x;
    double get maxX => minX + maxWindowSizeSeconds;
    double get minY => _minY;
    double get maxY => _maxY;
    double get windowSize => _points.isEmpty ? 0 : _points.last.point.x - _points.first.point.x;
    bool get isReady => windowSize >= minWindowSizeSeconds;

    void reset() {
        _points.clear();
        _skipped = 0;
        _index = 0;
        notifyListeners();
    }

    bool addPoint(double x, double y) {
        if (_skipped < skipFirst) {
            _skipped++;
            return false;
        }

        _index = (_index + 1) % selectEveryN;
        if (_index > 0) {
            return false;
        }

        _points.add(PointEntry(x, y));
        while (windowSize > maxWindowSizeSeconds) {
            _points.remove(_points.first);
        }

        _minY = double.maxFinite;
        _maxY = 0;
        
        for (var point in _points) {
          _minY = min(_minY, point.point.y);
          _maxY = max(_maxY, point.point.y);
        }

        notifyListeners();

        return true;
    }

    List<FlSpot> getPoints() {
        return _points.map((entry) => entry.point).toList();
    }
}