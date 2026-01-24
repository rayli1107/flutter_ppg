import 'dart:collection';
import 'dart:core';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

typedef Point = ({double x, double y});

class TestData extends ChangeNotifier {
    final List<FlSpot> _points = [];
    UnmodifiableListView<FlSpot> get points =>
      UnmodifiableListView(_points);

    void addPoint(double x, double y) {
        _points.add(FlSpot(x, y));
        notifyListeners();
    }
}
