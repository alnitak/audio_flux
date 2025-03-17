/// The parameters used to configure the waveform painter.
class WaveformPainterParams {
  ///
  const WaveformPainterParams({
    this.barsWidth = 1,
    this.barSpacingScale = 0,
    this.chunkSize = 256,
  }) : assert(
          chunkSize > 0 && chunkSize <= 256,
          'chunkSize must be between 1 and 256',
        );

  /// The size of a bar in pixels.
  final int barsWidth;

  /// The size of spacing between bars in pixels.
  final double barSpacingScale;

  /// The number of new data to average and add to the waveform.
  /// The higher the number, the slower the waveform is moving.
  /// This should be >= 1 and <= 256.
  final int chunkSize;

  ///
  WaveformPainterParams copyWith({
    int? barsWidth,
    double? barSpacingScale,
    int? chunkSize,
  }) {
    return WaveformPainterParams(
      barsWidth: barsWidth ?? this.barsWidth,
      barSpacingScale: barSpacingScale ?? this.barSpacingScale,
      chunkSize: chunkSize ?? this.chunkSize,
    );
  }
}
