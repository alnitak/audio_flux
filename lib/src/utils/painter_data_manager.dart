import 'dart:typed_data' show Float32List;

class PainterDataManager {
  Float32List _data = Float32List(0);

  void ensureCapacity(int barCount) {
    if (_data.length != barCount) {
      final newData = Float32List(barCount);
      final minLength = _data.length < barCount ? _data.length : barCount;
      for (var i = 0; i < minLength; i++) {
        newData[i] = _data[i];
      }
      _data = newData;
    }
  }

  Float32List get data => _data;
}
