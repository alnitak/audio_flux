// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:audio_flux/audio_flux.dart';
import 'package:audio_flux/src/utils/painter_data_manager.dart';
import 'package:audio_flux/src/utils/shader_params.dart';

class FftParams {
  factory FftParams({
    int minBinIndex = 0,
    int maxBinIndex = 255,
    int shrinkTo = 256,
    double barSpacingScale = 0,
    double fftSmoothing = 0.93,
  }) {
    assert(
      minBinIndex >= 0 && maxBinIndex <= 255 && minBinIndex <= maxBinIndex,
      'minBinIndex and maxIndex must be between 0 and 255 and '
      'minBinIndex must be <= maxIndex',
    );

    var effectiveShrinkTo = shrinkTo == -1 ? maxBinIndex - minBinIndex + 1 : shrinkTo;

    if (effectiveShrinkTo > maxBinIndex - minBinIndex + 1) {
      effectiveShrinkTo = maxBinIndex - minBinIndex + 1;
      debugPrint(
        'shrinkTo is greater than maxIndex-minBinIndex+1. '
        'Automatically set to maxIndex-minBinIndex+1: $shrinkTo',
      );
    }

    return FftParams._internal(
      minBinIndex: minBinIndex,
      maxBinIndex: maxBinIndex,
      shrinkTo: effectiveShrinkTo,
      barSpacingScale: barSpacingScale,
      fftSmoothing: fftSmoothing,
    );
  }

  /// Creates a [FftParams] with default values to be used as const.
  const FftParams.safe({
    this.minBinIndex = 0,
    this.maxBinIndex = 255,
    this.shrinkTo = 256,
    this.barSpacingScale = 0,
    this.fftSmoothing = 0.93,
  });

  const FftParams._internal({
    required this.minBinIndex,
    required this.maxBinIndex,
    required this.shrinkTo,
    required this.barSpacingScale,
    required this.fftSmoothing,
  });

  final int minBinIndex;
  final int maxBinIndex;
  final int shrinkTo;
  final double barSpacingScale;
  
  /// The smoothing factor for the FFT. This is used to smooth the FFT data.
  /// This should be between 0 and 1. 0 is no smoothing, 1 is full smoothing.
  final double fftSmoothing;

  FftParams copyWith({
    int? minBinIndex,
    int? maxBinIndex,
    int? shrinkTo,
    double? barSpacingScale,
    double? fftSmoothing,
  }) {
    return FftParams(
      minBinIndex: minBinIndex ?? this.minBinIndex,
      maxBinIndex: maxBinIndex ?? this.maxBinIndex,
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
  const PainterParams({
    this.backgroundColor = Colors.black,
    this.backgroundGradient,
    this.barColor = Colors.yellow,
    this.barGradient,
    this.audioScale = 1,
    this.fftParams = const FftParams.safe(),
    this.waveformParams = const WaveformParams(),
    this.shaderParams = const ShaderParams(),
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
  /// minBinIndex and maxBinIndex.
  final FftParams fftParams;

  /// The parameters for the waveform.
  final WaveformParams waveformParams;

  /// The parameters for the shader.
  final ShaderParams shaderParams;


  PainterParams copyWith({
    Color? backgroundColor,
    Color? barColor,
    Gradient? backgroundGradient,
    Gradient? barGradient,
    double? audioScale,
    FftParams? fftParams,
    WaveformParams? waveformParams,
    ShaderParams? shaderParams,
  }) {
    return PainterParams(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      barColor: barColor ?? this.barColor,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      barGradient: barGradient ?? this.barGradient,
      audioScale: audioScale ?? this.audioScale,
      fftParams: fftParams ?? this.fftParams,
      waveformParams: waveformParams ?? this.waveformParams,
      shaderParams: shaderParams ?? this.shaderParams,
    );
  }
}
