import 'dart:collection';

import 'package:fl_chart/fl_chart.dart';

final class PointEntry extends LinkedListEntry<PointEntry> {
    final FlSpot point;
    PointEntry(double x, double y) : point = FlSpot(x, y);
}

class GraphData {
    GraphData({required this.windowSize});

    final double windowSize;
    final LinkedList<PointEntry> _points = LinkedList<PointEntry>();

    double _yRange = 1;
    int _skipIndex = 0;

    double get minX => _points.first.point.x;
    double get maxX => minX + windowSize;
    double get minY => -1 * _yRange;
    double get maxY => _yRange;
    
    void reset() {
        _points.clear();
        _skipIndex = 0;
        _yRange = 1;
    }

    bool addPoint(double x, double y) {
        bool skip = _skipIndex > 0;
        _skipIndex = (_skipIndex + 1) % 3;
        if (skip) {
            return false;;
        }

        if (y > _yRange) {
            _yRange = y;
        } else if (y < -1 * _yRange) {
            _yRange = -1 * y;
        }
        _points.add(PointEntry(x, y));
        while (_points.first.point.x <
               _points.last.point.x - windowSize) {
            _points.remove(_points.first);
        }
        return true;
    }

    List<FlSpot> getPoints() {
        return _points.map((entry) => entry.point).toList();
    }
}