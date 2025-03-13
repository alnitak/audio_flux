import 'package:flutter/material.dart';
import 'package:audio_flux/audio_flux.dart';

class AudioVisualizerModel extends ChangeNotifier {
  FluxType fluxType = FluxType.fft;
  DataSources dataSource = DataSources.recorder;
  PainterParams _painterParams = PainterParams();
  FftParams _fftParams = const FftParams.safe();
  WaveformParams _waveformParams = const WaveformParams();
  ShaderParams _shaderParams = ShaderParams();

  PainterParams get painterParams => _painterParams;
  FftParams get fftParams => _fftParams;
  WaveformParams get waveformParams => _waveformParams;
  ShaderParams get shaderParams => _shaderParams;

  void updateFluxType({FluxType? type}) {
    fluxType = type ?? FluxType.fft;
    notifyListeners();
  }

  void updateDataSource({DataSources? source}) {
    dataSource = source ?? DataSources.recorder;
    notifyListeners();
  }

  void updatePainterParams({
    Color? backgroundColor,
    Color? barColor,
    Gradient? backgroundGradient,
    Gradient? barGradient,
    double? audioScale,
  }) {
    _painterParams = _painterParams.copyWith(
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
    int? shrinkTo,
    double? barSpacingScale,
    double? fftSmoothing,
  }) {
    _fftParams = _fftParams.copyWith(
      minBinIndex: minBinIndex,
      maxBinIndex: maxBinIndex,
      shrinkTo: shrinkTo,
      barSpacingScale: barSpacingScale,
      fftSmoothing: fftSmoothing,
    );
    _painterParams = _painterParams.copyWith(fftParams: _fftParams);
    notifyListeners();
  }

  void updateWaveformParams({
    int? barsWidth,
    double? barSpacingScale,
    int? chunkSize,
  }) {
    _waveformParams = _waveformParams.copyWith(
      barsWidth: barsWidth,
      barSpacingScale: barSpacingScale,
      chunkSize: chunkSize,
    );
    _painterParams = _painterParams.copyWith(waveformParams: _waveformParams);
    notifyListeners();
  }

  void updateShaderParams({
    int? minBinIndex,
    int? maxBinIndex,
    double? fftSmoothing,
    List<ShaderParam>? params,
    List<ShaderParamRange>? paramsRange,
  }) {
    _shaderParams = _shaderParams.copyWith(
      fftSmoothing: _shaderParams.fftSmoothing.copyWith(value: fftSmoothing),
      bins: _shaderParams.bins.copyWith(
        minValue: minBinIndex?.toDouble(),
        maxValue: maxBinIndex?.toDouble(),
      ),
      params: params,
      paramsRange: paramsRange,
    );
    _painterParams = _painterParams.copyWith(shaderParams: _shaderParams);
    notifyListeners();
  }
}
