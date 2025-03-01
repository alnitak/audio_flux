import 'dart:typed_data';

import 'package:audio_flux/src/waveform/waveform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

enum DataSources {
  soloud,
  recorder,
}

enum FluxType {
  waveform,
}

typedef DataCallback = Float32List Function({bool alwaysReturnData});

class AudioFlux extends StatefulWidget {
  const AudioFlux({
    super.key,
    required this.dataSource,
    required this.fluxType,
    required this.waveformParams,
  });

  final DataSources dataSource;
  final FluxType fluxType;
  final WaveformParams waveformParams;

  @override
  State<AudioFlux> createState() => _AudioFluxState();
}

class _AudioFluxState extends State<AudioFlux>
    with SingleTickerProviderStateMixin {
  final recorder = Recorder.instance;
  final soloud = SoLoud.instance;
  DataCallback? dataCallback;
  AudioData? audioData;
  Ticker? ticker;
  Widget? painterWidget;

  @override
  void initState() {
    super.initState();
    setupWidgetAndCallback();
    ticker = createTicker((_) {
      if (mounted) {
        if (widget.dataSource == DataSources.soloud) {
          audioData!.updateSamples();
        }
        setState(() {});
      }
    });
    ticker!.start();
  }

  @override
  void didUpdateWidget(covariant AudioFlux oldWidget) {
    setupWidgetAndCallback();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    ticker?.dispose();
    audioData?.dispose();
    soloud.deinit();
    recorder.deinit();
    super.dispose();
  }

  void setupWidgetAndCallback() {
    switch (widget.fluxType) {
      case FluxType.waveform:

        /// Setup the painter and the callback needed by [FluxType.waveform].
        switch (widget.dataSource) {
          case DataSources.soloud:
            audioData = AudioData(GetSamplesKind.wave);
            dataCallback = ({bool alwaysReturnData = false}) =>
                audioData!.getAudioData(alwaysReturnData: alwaysReturnData);
            break;
          case DataSources.recorder:
            dataCallback = ({bool alwaysReturnData = false}) =>
                Recorder.instance.getWave(alwaysReturnData: alwaysReturnData);
            break;
        }
        painterWidget = Waveform(
          dataCallback: dataCallback!,
          params: widget.waveformParams,
        );
        break;
    }
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
        key: UniqueKey(),
        builder: (context) {
          return painterWidget!;
        });
  }
}
