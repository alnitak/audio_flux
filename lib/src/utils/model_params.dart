// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:audio_flux/audio_flux.dart';
import 'package:audio_flux/src/utils/painter_data_manager.dart';
import 'package:audio_flux/src/utils/shader_params.dart';

class FftParams {
  const FftParams({
    this.minBinIndex = 0,
    this.maxBinIndex = 255,
    this.fftSmoothing = 0.93,
  }) : assert(
          minBinIndex >= 0 && maxBinIndex <= 255 && minBinIndex <= maxBinIndex,
          'minBinIndex and maxIndex must be between 0 and 255 and '
          'minBinIndex must be <= maxIndex',
        );

  final int minBinIndex;
  final int maxBinIndex;
  final double fftSmoothing;

  FftParams copyWith({
    int? minBinIndex,
    int? maxBinIndex,
    double? fftSmoothing,
  }) {
    return FftParams(
      minBinIndex: minBinIndex ?? this.minBinIndex,
      maxBinIndex: maxBinIndex ?? this.maxBinIndex,
      fftSmoothing: fftSmoothing ?? this.fftSmoothing,
    );
  }
}

class FftPainterParams {
  const FftPainterParams({
    this.shrinkTo = 256,
    this.barSpacingScale = 0,
  });

  final int shrinkTo;
  final double barSpacingScale;

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

class WaveformPainterParams {
  const WaveformPainterParams({
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

class ModelParams {
  const ModelParams({
    this.backgroundColor = Colors.black,
    this.backgroundGradient,
    this.barColor = Colors.yellow,
    this.barGradient,
    this.audioScale = 1,
    this.fftParams = const FftParams(),
    this.fftPainterParams = const FftPainterParams(),
    this.waveformParams = const WaveformPainterParams(),
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

  /// The parameters for the FFT.
  final FftParams fftParams;

  /// The parameters for the FFT. It displays only the bars between
  /// minBinIndex and maxBinIndex.
  final FftPainterParams fftPainterParams;

  /// The parameters for the waveform.
  final WaveformPainterParams waveformParams;

  /// The parameters for the shader.
  final ShaderParams shaderParams;

  ModelParams copyWith({
    Color? backgroundColor,
    Color? barColor,
    Gradient? backgroundGradient,
    Gradient? barGradient,
    double? audioScale,
    FftParams? fftParams,
    FftPainterParams? fftPainterParams,
    WaveformPainterParams? waveformParams,
    ShaderParams? shaderParams,
  }) {
    return ModelParams(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      barColor: barColor ?? this.barColor,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      barGradient: barGradient ?? this.barGradient,
      audioScale: audioScale ?? this.audioScale,
      fftParams: fftParams ?? this.fftParams,
      fftPainterParams: fftPainterParams ?? this.fftPainterParams,
      waveformParams: waveformParams ?? this.waveformParams,
      shaderParams: shaderParams ?? this.shaderParams,
    );
  }
}
