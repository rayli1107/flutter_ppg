class PPGScreenSettings
{
    bool _flashlight;
    final void Function(bool) _onToggleFlashlight;

    int _length;
    final void Function(int) _onLengthUpdate;

    bool get flashlight => _flashlight;
    set flashlight(bool value) {
        _flashlight = value;
        _onToggleFlashlight(value);
    }

    int get length => _length;
    set length(int value) {
        _length = value;
        _onLengthUpdate(value);
    }

    PPGScreenSettings({
        required void Function(int) onLengthUpdate,
        required void Function(bool) onToggleFlashlight,
        int length = 60,
        bool flashlight = false}) : 
        _onLengthUpdate = onLengthUpdate,
        _onToggleFlashlight = onToggleFlashlight,
        _flashlight = flashlight,
        _length = length;
}
