// ignore_for_file: public_member_api_docs

import 'package:audio_flux/audio_flux.dart';
import 'package:flutter/material.dart';

/// The model to manage `AudioFlux` parameters.
class AudioVisualizerModel extends ChangeNotifier {
  FluxType fluxType = FluxType.fft;
  DataSources dataSource = DataSources.recorder;
  ModelParams _modelParams = const ModelParams();
  FftParams _fftParams = const FftParams();
  FftPainterParams _fftPainterParams = const FftPainterParams();
  WaveformPainterParams _waveformPainterParams = const WaveformPainterParams();
  ShaderParams _shaderParams = const ShaderParams();

  ModelParams get modelParams => _modelParams;
  FftParams get fftParams => _fftParams;
  FftPainterParams get fftPainterParams => _fftPainterParams;
  WaveformPainterParams get waveformParams => _waveformPainterParams;
  ShaderParams get shaderParams => _shaderParams;

  void updateFluxType({FluxType? type}) {
    fluxType = type ?? FluxType.fft;
    notifyListeners();
  }

  void updateDataSource({DataSources? source}) {
    dataSource = source ?? DataSources.recorder;
    notifyListeners();
  }

  void updateModelParams({
    Color? backgroundColor,
    Color? barColor,
    Gradient? backgroundGradient,
    Gradient? barGradient,
    double? audioScale,
  }) {
    _modelParams = _modelParams.copyWith(
      backgroundColor: backgroundColor,
      barColor: barColor,
      backgroundGradient: backgroundGradient,
      barGradient: barGradient,
      audioScale: audioScale,
    );
    notifyListeners();
  }

  void updateFftParams({
    int? minBinIndex,
    int? maxBinIndex,
    double? fftSmoothing,
  }) {
    _fftParams = _fftParams.copyWith(
      minBinIndex: minBinIndex,
      maxBinIndex: maxBinIndex,
      fftSmoothing: fftSmoothing,
    );
    _modelParams = _modelParams.copyWith(fftParams: _fftParams);

    /// Fix the [_fftParams.shrinkTo] value
    if (_fftPainterParams.shrinkTo >
        _fftParams.maxBinIndex - _fftParams.minBinIndex + 1) {
      _fftPainterParams = _fftPainterParams.copyWith(
        shrinkTo: _fftParams.maxBinIndex - _fftParams.minBinIndex + 1,
      );
      _modelParams = _modelParams.copyWith(fftPainterParams: _fftPainterParams);
    }
    notifyListeners();
  }

  void updateFftPainterParams({
    int? shrinkTo,
    double? barSpacingScale,
    double? barRadius,
  }) {
    if (shrinkTo != null) {
      var effectiveShrinkTo = shrinkTo == -1
          ? _fftParams.maxBinIndex - _fftParams.minBinIndex + 1
          : shrinkTo;

      if (effectiveShrinkTo >
          _fftParams.maxBinIndex - _fftParams.minBinIndex + 1) {
        effectiveShrinkTo = _fftParams.maxBinIndex - _fftParams.minBinIndex + 1;
        debugPrint(
          'shrinkTo is greater than maxIndex-minBinIndex+1. '
          'Automatically set to maxIndex-minBinIndex+1: $shrinkTo',
        );
      }
    }

    _fftPainterParams = _fftPainterParams.copyWith(
      shrinkTo: shrinkTo,
      barSpacingScale: barSpacingScale,
      barRadius: barRadius,
    );
    _modelParams = _modelParams.copyWith(fftPainterParams: _fftPainterParams);
    notifyListeners();
  }

  void updateWaveformPainterParams({
    int? barsWidth,
    double? barSpacingScale,
    double? barRadius,
    int? chunkSize,
  }) {
    _waveformPainterParams = _waveformPainterParams.copyWith(
      barsWidth: barsWidth,
      barSpacingScale: barSpacingScale,
      barRadius: barRadius,
      chunkSize: chunkSize,
    );
    _modelParams =
        _modelParams.copyWith(waveformParams: _waveformPainterParams);
    notifyListeners();
  }

  void updateShaderParams({
    String? shaderName,
    String? shaderPath,
    List<ShaderParam>? params,
    List<ShaderParamRange>? paramsRange,
    List<TextureChannel>? textureChannels,
  }) {
    _shaderParams = _shaderParams.copyWith(
      shaderName: shaderName,
      shaderPath: shaderPath,
      params: params,
      paramsRange: paramsRange,
      textureChannels: textureChannels,
    );
    _modelParams = _modelParams.copyWith(shaderParams: _shaderParams);
    notifyListeners();
  }
}
