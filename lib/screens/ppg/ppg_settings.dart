import 'package:flutter/foundation.dart';

class PPGScreenSettings extends ChangeNotifier
{
    bool _flashlight;
    int _length;

    bool get flashlight => _flashlight;
    set flashlight(bool value) {
        if (_flashlight != value) {
            _flashlight = value;
            notifyListeners();
        }
    }

    int get length => _length;
    set length(int value) {
        if (_length != value) {
            _length = value;
            notifyListeners();
        }
    }

    PPGScreenSettings({
        int length = 30,
        bool flashlight = false}) : 
        _flashlight = flashlight,
        _length = length;
}
