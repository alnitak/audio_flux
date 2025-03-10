// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:audio_flux/src/utils/painter_data_manager.dart';

class FftParams {
  factory FftParams({
    int minIndex = 0,
    int maxIndex = 255,
    int shrinkTo = 256,
    double barSpacingScale = 0.5,
    double fftSmoothing = 0.93,
  }) {
    assert(
      minIndex >= 0 && maxIndex <= 255 && minIndex <= maxIndex,
      'minIndex and maxIndex must be between 0 and 255 and '
      'minIndex must be <= maxIndex',
    );

    var effectiveShrinkTo = shrinkTo == -1 ? maxIndex - minIndex + 1 : shrinkTo;

    if (effectiveShrinkTo > maxIndex - minIndex + 1) {
      effectiveShrinkTo = maxIndex - minIndex + 1;
      debugPrint(
        'shrinkTo is greater than maxIndex-minIndex+1. '
        'Automatically set to maxIndex-minIndex+1: $shrinkTo',
      );
    }

    return FftParams._internal(
      minIndex: minIndex,
      maxIndex: maxIndex,
      shrinkTo: effectiveShrinkTo,
      barSpacingScale: barSpacingScale,
      fftSmoothing: fftSmoothing,
    );
  }

  /// Creates a [FftParams] with default values to be used as const.
  const FftParams.safe({
    this.minIndex = 0,
    this.maxIndex = 255,
    this.shrinkTo = 256,
    this.barSpacingScale = 0.5,
    this.fftSmoothing = 0.93,
  });

  const FftParams._internal({
    required this.minIndex,
    required this.maxIndex,
    required this.shrinkTo,
    required this.barSpacingScale,
    required this.fftSmoothing,
  });

  final int minIndex;
  final int maxIndex;
  final int shrinkTo;
  final double barSpacingScale;
  
  /// The smoothing factor for the FFT. This is used to smooth the FFT data.
  /// This should be between 0 and 1. 0 is no smoothing, 1 is full smoothing.
  final double fftSmoothing;

  FftParams copyWith({
    int? minIndex,
    int? maxIndex,
    int? shrinkTo,
    double? barSpacingScale,
    double? fftSmoothing,
  }) {
    return FftParams(
      minIndex: minIndex ?? this.minIndex,
      maxIndex: maxIndex ?? this.maxIndex,
      shrinkTo: shrinkTo ?? this.shrinkTo,
      barSpacingScale: barSpacingScale ?? this.barSpacingScale,
      fftSmoothing: fftSmoothing ?? this.fftSmoothing,
    );
  }
}

class WaveformParams {
  const WaveformParams({
    this.barsWidth = 1,
    this.barSpacingScale = 0,
    this.chunkSize = 256,
  }) : assert(chunkSize > 0 && chunkSize <= 256,
            'chunkSize must be between 1 and 256');

  /// The size of a bar in pixels.
  final int barsWidth;

  /// The size of spacing between bars in pixels.
  final double barSpacingScale;

  /// The number of new data to average and add to the waveform.
  /// The higher the number, the slower the waveform is moving.
  /// This should be >= 1 and <= 256.
  final int chunkSize;

  WaveformParams copyWith({
    int? barsWidth,
    double? barSpacingScale,
    int? chunkSize,
  }) {
    return WaveformParams(
      barsWidth: barsWidth ?? this.barsWidth,
      barSpacingScale: barSpacingScale ?? this.barSpacingScale,
      chunkSize: chunkSize ?? this.chunkSize,
    );
  }
}

class PainterParams {
  PainterParams({
    this.backgroundColor = Colors.black,
    this.backgroundGradient,
    this.barColor = Colors.yellow,
    this.barGradient,
    this.audioScale = 1,
    this.fftParams = const FftParams.safe(),
    this.waveformParams = const WaveformParams(),
  });

  /// The data manager used to store the waveform data displayed
  /// in CustomPainter.
  PainterDataManager get dataManager =>
      _internalDataManager ??= PainterDataManager();

  /// Internal data manager
  static PainterDataManager? _internalDataManager;

  /// The background color of the waveform.
  final Color backgroundColor;

  /// The color of the waveform bars.
  final Color barColor;

  /// The gradient of the waveform background. If provided, this will
  /// override [backgroundColor].
  final Gradient? backgroundGradient;

  /// The gradient of the waveform bars. If provided, this will
  /// override [barColor].
  final Gradient? barGradient;

  /// The scale of the audio data. This is used to scale the bars height.
  /// This should be > 0.
  final double audioScale;

  /// The parameters for the FFT. It displays only the bars between
  /// minIndex and maxIndex.
  final FftParams fftParams;

  /// The parameters for the waveform.
  final WaveformParams waveformParams;

  PainterParams copyWith({
    Color? backgroundColor,
    Color? barColor,
    Gradient? backgroundGradient,
    Gradient? barGradient,
    double? audioScale,
    double? fftSmoothing,
    FftParams? fftParams,
    WaveformParams? waveformParams,
  }) {
    return PainterParams(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      barColor: barColor ?? this.barColor,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      barGradient: barGradient ?? this.barGradient,
      audioScale: audioScale ?? this.audioScale,
      fftParams: fftParams ?? this.fftParams,
      waveformParams: waveformParams ?? this.waveformParams,
    );
  }
}
