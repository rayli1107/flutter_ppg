import 'dart:collection';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

final class PointEntry extends LinkedListEntry<PointEntry> {
    final FlSpot point;
    PointEntry(double x, double y) : point = FlSpot(x, y);
}

class GraphData {
    GraphData({required this.windowSize});

    final double windowSize;
    final LinkedList<PointEntry> _points = LinkedList<PointEntry>();

    double _minY = 0;
    double _maxY = 0;
    int _skipIndex = 0;

    double get minX => _points.first.point.x;
    double get maxX => minX + windowSize;
    double get minY => _minY;
    double get maxY => _maxY;

    void reset() {
        _points.clear();
        _skipIndex = 0;
    }

    bool addPoint(double x, double y) {
        bool skip = _skipIndex > 0;
        _skipIndex = (_skipIndex + 1) % 3;
        if (skip) {
            return false;
        }

        _points.add(PointEntry(x, y));
        while (_points.first.point.x <
               _points.last.point.x - windowSize) {
            _points.remove(_points.first);
        }

        _minY = double.maxFinite;
        _maxY = 0;
        
        for (var point in _points) {
          _minY = min(_minY, point.point.y);
          _maxY = max(_maxY, point.point.y);
        }

        return true;
    }

    List<FlSpot> getPoints() {
        return _points.map((entry) => entry.point).toList();
    }
}