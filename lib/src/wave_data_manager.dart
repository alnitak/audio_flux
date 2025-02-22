import 'dart:typed_data' show Float32List;

class WaveDataManager {
  static WaveDataManager? _instance;
  Float32List _waveData = Float32List(0);

  WaveDataManager._();

  static WaveDataManager get instance {
    _instance ??= WaveDataManager._();
    return _instance!;
  }

  void ensureCapacity(int barCount) {
    if (_waveData.length != barCount) {
      final newData = Float32List(barCount);
      final minLength = _waveData.length < barCount ? _waveData.length : barCount;
      for (var i = 0; i < minLength; i++) {
        newData[i] = _waveData[i];
      }
      _waveData = newData;
    }
  }

  Float32List get data => _waveData;
}
