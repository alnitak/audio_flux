import 'package:audio_flux/audio_flux.dart';
import 'package:audio_flux/src/utils/painter_data_manager.dart';
import 'package:flutter/material.dart';

/// The parameters used to configure the AudioFlux widget.
class ModelParams {
  ///
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

  ///
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
