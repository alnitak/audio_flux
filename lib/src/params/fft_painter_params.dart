/// FFT painter params
class FftPainterParams {
  ///
  const FftPainterParams({
    this.shrinkTo = 256,
    this.barSpacingScale = 0,
    this.barRadius = 0,
  }) : assert(
          barRadius >= 0,
          'barRadius must be non-negative',
        );

  /// Shrink the FFT to this number of bars regardless the FftParams min and
  /// max bins values, but not less than min(maxBinIndex - minBinIndex + 1).
  final int shrinkTo;

  /// Bar spacing scale
  final double barSpacingScale;

  /// The radius of the bars in pixels.
  final double barRadius;

  ///
  FftPainterParams copyWith({
    int? shrinkTo,
    double? barSpacingScale,
    double? barRadius,
  }) {
    return FftPainterParams(
      shrinkTo: shrinkTo ?? this.shrinkTo,
      barSpacingScale: barSpacingScale ?? this.barSpacingScale,
      barRadius: barRadius ?? this.barRadius,
    );
  }
}
