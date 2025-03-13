import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audio_flux/src/painters/fft.dart';
import 'package:audio_flux/src/shaders/shader.dart';
import 'package:audio_flux/src/utils/model_params.dart';
import 'package:audio_flux/src/painters/waveform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_soloud/flutter_soloud.dart' show AudioData, GetSamplesKind, SoLoud;

enum DataSources {
  soloud,
  recorder,
}

enum FluxType {
  waveform,
  fft,
  shader
}

typedef DataCallback = Float32List Function({bool alwaysReturnData});

class AudioFlux extends StatefulWidget {
  const AudioFlux({
    super.key,
    required this.dataSource,
    required this.fluxType,
    required this.modelParams,
  });

  final DataSources dataSource;
  final FluxType fluxType;
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
  void initState() {
    super.initState();
    // setupWidgetAndCallback();
  }

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
        break;
      case DataSources.recorder:
        audioData?.dispose();
        audioData = null;
        dataCallback = ({bool alwaysReturnData = false}) =>
            Recorder.instance.getWave(alwaysReturnData: alwaysReturnData);
        break;
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
        break;
      case DataSources.recorder:
        audioData?.dispose();
        audioData = null;
        Recorder.instance
            .setFftSmoothing(widget.modelParams.fftParams.fftSmoothing);
        dataCallback = ({bool alwaysReturnData = true}) =>
            Recorder.instance.getTexture(alwaysReturnData: alwaysReturnData);
        break;
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
        break;

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
        break;

      case FluxType.shader:
      
        _setDataAsLinear();
        visualizerWidget = Shader(
          dataCallback: dataCallback!,
          audioData: audioData,
          params: widget.modelParams,
        );
        break;
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
      return SizedBox.shrink();
    }

    return Builder(
      builder: (context) {
        return Column(
          children: [
            SizedBox(
              width: 500,
              height: 300,
              child: visualizerWidget!,
            ),
          ],
        );
      },
    );
  }
}

class SamplerTickerUpdater extends StatefulWidget {
  const SamplerTickerUpdater({
    super.key,
    required this.child,
    required this.audioData,
  });

  final Widget child;
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
