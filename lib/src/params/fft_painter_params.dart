/// FFT painter params
class FftPainterParams {
  ///
  const FftPainterParams({
    this.shrinkTo = 256,
    this.barSpacingScale = 0,
  });

  /// Shrink the FFT to this number of bars regardless the FftParams min and
  /// max bins values, but not less than min(maxBinIndex - minBinIndex + 1).
  final int shrinkTo;

  /// Bar spacing scale
  final double barSpacingScale;

  ///
  FftPainterParams copyWith({
    int? shrinkTo,
    double? barSpacingScale,
  }) {
    return FftPainterParams(
      shrinkTo: shrinkTo ?? this.shrinkTo,
      barSpacingScale: barSpacingScale ?? this.barSpacingScale,
    );
  }
}
