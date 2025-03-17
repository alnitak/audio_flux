import 'dart:typed_data' show Float32List;

/// Class to manage the data used by the waveform and FFT painters.
class PainterDataManager {
  /// The data used by the painter.
  Float32List _data = Float32List(0);

  /// Ensure that the data array has the specified capacity
  /// ie when the canvas is resized.
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

  /// The data used by the painter.
  Float32List get data => _data;
}
