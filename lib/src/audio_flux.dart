import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audio_flux/src/painters/fft.dart';
import 'package:audio_flux/src/painters/waveform.dart';
import 'package:audio_flux/src/params/model_params.dart';
import 'package:audio_flux/src/shaders/shader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_soloud/flutter_soloud.dart'
    show AudioData, GetSamplesKind, SoLoud;

/// The source of the audio data.
enum DataSources {
  /// The audio data is acquired from flutter_soloud.
  soloud,

  /// The audio data is acquired from flutter_recorder.
  recorder,
}

/// The type of the visualizer.
enum FluxType {
  /// Use the waveformr CustomPainter to draw the waveform.
  waveform,

  /// Use the FFT CustomPainter to draw the FFT.
  fft,

  /// Use a shader and draw it.
  shader,
}

/// Definition for the callback that returns the audio data.
typedef DataCallback = Float32List Function({bool alwaysReturnData});

/// The main widget which visualizes the audio data.
///
/// It can render the waveform, the FFT, or a shader. The waveform and the FFT
/// are implemented as CustomPainters. While the shader is implemented using
/// [shader_buffers](https://pub.dev/packages/shader_buffers) package.
///
/// The audio data can be acquired from flutter_soloud or flutter_recorder
/// using the [DataSources] enum.
///
/// The visualizer kind can be set using the [FluxType] enum.
///
/// The parameters for the waveform, the FFT, or the shader can be set
/// using the [ModelParams] class.
class AudioFlux extends StatefulWidget {
  ///
  const AudioFlux({
    required this.dataSource,
    required this.fluxType,
    required this.modelParams,
    super.key,
  });

  /// The source of the audio data.
  final DataSources dataSource;

  /// The type of the visualizer.
  final FluxType fluxType;

  /// The parameters for the waveform, the FFT, or the shader.
  final ModelParams modelParams;

  @override
  State<AudioFlux> createState() => _AudioFluxState();
}

class _AudioFluxState extends State<AudioFlux> {
  final recorder = Recorder.instance;
  final soloud = SoLoud.instance;
  DataCallback? dataCallback;
  AudioData? audioData;
  Widget? visualizerWidget;

  @override
  void didUpdateWidget(covariant AudioFlux oldWidget) {
    setupWidgetAndCallback();
    super.didUpdateWidget(oldWidget);
  }

  /// Set the type of data acquired as wave.
  void _setDataAsWave() {
    switch (widget.dataSource) {
      case DataSources.soloud:
        audioData?.dispose();
        audioData = AudioData(GetSamplesKind.wave);
        dataCallback = ({bool alwaysReturnData = false}) =>
            audioData!.getAudioData(alwaysReturnData: alwaysReturnData);
      case DataSources.recorder:
        audioData?.dispose();
        audioData = null;
        dataCallback = Recorder.instance.getWave;
    }
  }

  /// Set the type of data acquired as linear.
  void _setDataAsLinear() {
    switch (widget.dataSource) {
      case DataSources.soloud:
        audioData?.dispose();
        audioData = AudioData(GetSamplesKind.linear);
        SoLoud.instance
            .setFftSmoothing(widget.modelParams.fftParams.fftSmoothing);
        dataCallback = ({bool alwaysReturnData = true}) =>
            audioData!.getAudioData(alwaysReturnData: alwaysReturnData);
      case DataSources.recorder:
        audioData?.dispose();
        audioData = null;
        Recorder.instance
            .setFftSmoothing(widget.modelParams.fftParams.fftSmoothing);
        dataCallback = Recorder.instance.getTexture;
    }
  }

  @override
  void dispose() {
    audioData?.dispose();
    soloud.deinit();
    recorder.deinit();
    super.dispose();
  }

  Future<void> setupWidgetAndCallback() async {
    switch (widget.fluxType) {
      case FluxType.waveform:

        /// Setup the painter and the callback needed by [FluxType.waveform].
        _setDataAsWave();
        visualizerWidget = SamplerTickerUpdater(
          audioData: audioData,
          child: Waveform(
            dataCallback: dataCallback!,
            params: widget.modelParams,
          ),
        );

      case FluxType.fft:

        /// Setup the painter and the callback needed by [FluxType.fft].
        _setDataAsLinear();
        visualizerWidget = SamplerTickerUpdater(
          audioData: audioData,
          child: Fft(
            dataCallback: dataCallback!,
            params: widget.modelParams,
          ),
        );

      case FluxType.shader:
        _setDataAsLinear();
        visualizerWidget = Shader(
          dataCallback: dataCallback!,
          audioData: audioData,
          params: widget.modelParams,
        );
    }
  }

  Future<ui.Image?> buildImage(Uint8List bmp) async {
    final completer = Completer<ui.Image>();

    ui.decodeImageFromList(bmp, completer.complete);

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (!((widget.dataSource == DataSources.soloud &&
            soloud.isInitialized &&
            soloud.getVisualizationEnabled()) ||
        (widget.dataSource == DataSources.recorder &&
            recorder.isDeviceInitialized()))) {
      return const SizedBox.shrink();
    }

    return visualizerWidget!;
  }
}

/// Simple widget that uses the [Ticker] to update the audio data.
class SamplerTickerUpdater extends StatefulWidget {
  ///
  const SamplerTickerUpdater({
    required this.child,
    required this.audioData,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// The audio data.
  final AudioData? audioData;

  @override
  State<SamplerTickerUpdater> createState() => _SamplerTickerUpdaterState();
}

class _SamplerTickerUpdaterState extends State<SamplerTickerUpdater>
    with SingleTickerProviderStateMixin {
  late Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker((_) {
      if (mounted) {
        widget.audioData?.updateSamples();
        setState(() {});
      }
    });
    ticker.start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: UniqueKey(),
      child: widget.child,
    );
  }
}
