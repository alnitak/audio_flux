import 'dart:typed_data';

import 'package:audio_flux/src/painters/fft.dart';
import 'package:audio_flux/src/utils/painter_params.dart';
import 'package:audio_flux/src/painters/waveform.dart';
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
  fft,
}

typedef DataCallback = Float32List Function({bool alwaysReturnData});

class AudioFlux extends StatefulWidget {
  const AudioFlux({
    super.key,
    required this.dataSource,
    required this.fluxType,
    required this.painterParams,
  });

  final DataSources dataSource;
  final FluxType fluxType;
  final PainterParams painterParams;

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
            audioData?.dispose();
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
          params: widget.painterParams,
        );
        break;

      case FluxType.fft:

        /// Setup the painter and the callback needed by [FluxType.fft].
        switch (widget.dataSource) {
          case DataSources.soloud:
            audioData?.dispose();
            audioData = AudioData(GetSamplesKind.linear);
            SoLoud.instance
                .setFftSmoothing(widget.painterParams.fftParams.fftSmoothing);
            dataCallback = ({bool alwaysReturnData = true}) =>
                audioData!.getAudioData(alwaysReturnData: alwaysReturnData);
            break;
          case DataSources.recorder:
            Recorder.instance
                .setFftSmoothing(widget.painterParams.fftParams.fftSmoothing);
            dataCallback = ({bool alwaysReturnData = true}) => Recorder.instance
                .getTexture(alwaysReturnData: alwaysReturnData);
            break;
        }
        painterWidget = Fft(
          dataCallback: dataCallback!,
          params: widget.painterParams,
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
          return Column(
            children: [
              SizedBox(
                width: 500,
                height: 300,
                child: painterWidget!,
              ),
              if (widget.fluxType == FluxType.fft)
                SizedBox(
                  width: 500,
                  height: 300,
                  child: ColoredBox(
                    color: Colors.black,
                    child: RepaintBoundary(
                      child: ClipRRect(
                        child: CustomPaint(
                          painter: WavePainterOrig(
                            dataCallback: dataCallback,
                            painterParams: widget.painterParams,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        });
  }
}

class WavePainterOrig extends CustomPainter {
  const WavePainterOrig({
    required this.dataCallback,
    required this.painterParams,
  });
  final DataCallback? dataCallback;
  final PainterParams painterParams;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataCallback == null) {
      return;
    }
    final samples = dataCallback!();
    // Using `alwaysReturnData: true` this will always return a non-empty list
    // even if the audio data is the same as the previous one.
    if (samples.isEmpty) {
      return;
    }
    final barWidth = size.width / 256;
    final paint = Paint()
      ..strokeWidth = barWidth * 0.8
      ..color = Colors.yellowAccent;

    double waveHeight;
    double fftHeight;

    for (var i = 0; i < 256; i++) {
      try {
        final fftData = samples[i] * painterParams.audioScale;
        final waveData = samples[i + 256] * painterParams.audioScale;
        waveHeight = size.height * waveData * 0.5;
        fftHeight = size.height * fftData;
      } on Exception {
        waveHeight = 0;
        fftHeight = 0;
      }

      /// Draw the wave
      canvas
        ..drawRect(
          Rect.fromLTRB(
            barWidth * i,
            size.height / 4 - waveHeight / 2,
            barWidth * (i + 1),
            size.height / 4 + waveHeight / 2,
          ),
          paint,
        )

        /// Draw the fft
        ..drawLine(
          Offset(barWidth * i, size.height),
          Offset(barWidth * i, size.height - fftHeight),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
