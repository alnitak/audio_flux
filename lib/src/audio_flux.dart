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
import 'package:flutter_soloud/flutter_soloud.dart' show SoLoud;

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

class _AudioFluxState extends State<AudioFlux>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker;
  final recorder = Recorder.instance;
  final soloud = SoLoud.instance;

  StreamSubscription<dynamic>? _visSubscription;
  Float32List _latestWave = Float32List(512);
  Float32List _latestFft = Float32List(256);
  Float32List _combinedTexture = Float32List(512);

  DataCallback? dataCallback;
  Widget? visualizerWidget;
  final srcInput = ValueNotifier((isSoLoud: false, isRecording: false));

  @override
  void initState() {
    super.initState();
    ticker = createTicker((_) {
      if (!srcInput.value.isSoLoud &&
          widget.dataSource == DataSources.soloud &&
          soloud.isInitialized) {
        if (!soloud.getVisualizationEnabled()) {
          soloud.setVisualizationEnabled(true, windowSize: 512);
        }
        _subscribeToVisualization();
        if (visualizerWidget == null) {
          setupWidgetAndCallback();
        }
        srcInput.value = (isSoLoud: true, isRecording: false);
      } else if (!srcInput.value.isRecording &&
          widget.dataSource == DataSources.recorder &&
          recorder.isDeviceInitialized()) {
        if (!recorder.getVisualizationEnabled()) {
          recorder.setVisualizationEnabled(true, windowSize: 512);
        }
        _subscribeToVisualization();
        if (visualizerWidget == null) {
          setupWidgetAndCallback();
        }
        srcInput.value = (isSoLoud: false, isRecording: true);
      } else if (!srcInput.value.isRecording && !srcInput.value.isSoLoud) {
        visualizerWidget = null;
        srcInput.value = (isSoLoud: false, isRecording: false);
      }
    });
    ticker.start();
  }

  void _subscribeToVisualization() {
    _visSubscription?.cancel();
    _visSubscription = null;

    if (widget.dataSource == DataSources.soloud && soloud.isInitialized) {
      soloud.setFftSmoothing(widget.modelParams.fftParams.fftSmoothing);
      _visSubscription = soloud.audioVisualizationEvents.listen((data) {
        final wave = data.waveData;
        final fft = data.fftData;
        if (wave != null) {
          _latestWave = wave;
        }
        if (fft != null) {
          _latestFft = fft;
        }
      });
    } else if (widget.dataSource == DataSources.recorder &&
        recorder.isDeviceInitialized()) {
      recorder.setFftSmoothing(widget.modelParams.fftParams.fftSmoothing);
      _visSubscription = recorder.audioVisualizationEvents.listen((data) {
        final wave = data.waveData;
        final fft = data.fftData;
        if (wave != null) {
          _latestWave = wave;
        }
        if (fft != null) {
          _latestFft = fft;
        }
      });
    }
  }

  @override
  void dispose() {
    ticker.dispose();
    _visSubscription?.cancel();
    _visSubscription = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AudioFlux oldWidget) {
    if (oldWidget.dataSource != widget.dataSource) {
      _subscribeToVisualization();
    }
    setupWidgetAndCallback();
    super.didUpdateWidget(oldWidget);
  }

  /// Set the type of data acquired as wave.
  void _setDataAsWave() {
    dataCallback = ({bool alwaysReturnData = false}) => _latestWave;
  }

  /// Set the type of data acquired as FFT.
  void _setDataAsFft() {
    if (widget.dataSource == DataSources.soloud) {
      SoLoud.instance
          .setFftSmoothing(widget.modelParams.fftParams.fftSmoothing);
    } else {
      Recorder.instance
          .setFftSmoothing(widget.modelParams.fftParams.fftSmoothing);
    }
    dataCallback = ({bool alwaysReturnData = true}) => _latestFft;
  }

  /// Set the type of data acquired as linear (512 floats: 256 FFT + 256 Wave).
  void _setDataAsLinear() {
    if (widget.dataSource == DataSources.soloud) {
      SoLoud.instance
          .setFftSmoothing(widget.modelParams.fftParams.fftSmoothing);
    } else {
      Recorder.instance
          .setFftSmoothing(widget.modelParams.fftParams.fftSmoothing);
    }
    dataCallback = ({bool alwaysReturnData = true}) {
      if (_combinedTexture.length != 512) {
        _combinedTexture = Float32List(512);
      } else {
        _combinedTexture.fillRange(0, 512, 0);
      }

      final fftLength = _latestFft.length < 256 ? _latestFft.length : 256;
      final waveLength = _latestWave.length < 256 ? _latestWave.length : 256;

      for (var i = 0; i < fftLength; i++) {
        _combinedTexture[i] = _latestFft[i];
      }
      for (var i = 0; i < waveLength; i++) {
        _combinedTexture[256 + i] = _latestWave[i];
      }
      return _combinedTexture;
    };
  }

  /// Setup the painter and the callback needed by [FluxType.waveform],
  /// [FluxType.fft], and [FluxType.shader].
  Future<void> setupWidgetAndCallback() async {
    switch (widget.fluxType) {
      case FluxType.waveform:

        /// Setup the painter and the callback needed by [FluxType.waveform].
        _setDataAsWave();
        visualizerWidget = SamplerTickerUpdater(
          child: Waveform(
            dataCallback: dataCallback!,
            params: widget.modelParams,
          ),
        );

      case FluxType.fft:

        /// Setup the painter and the callback needed by [FluxType.fft].
        _setDataAsFft();
        visualizerWidget = SamplerTickerUpdater(
          child: Fft(
            dataCallback: dataCallback!,
            params: widget.modelParams,
          ),
        );

      case FluxType.shader:
        _setDataAsLinear();
        visualizerWidget = Shader(
          dataCallback: dataCallback!,
          params: widget.modelParams,
        );
    }
    Future.delayed(Duration.zero, () => setState(() {}));
  }

  /// Build an image to be passed to the shader.
  Future<ui.Image?> buildImage(Uint8List bmp) async {
    final completer = Completer<ui.Image>();

    ui.decodeImageFromList(bmp, completer.complete);

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (visualizerWidget == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder(
      valueListenable: srcInput,
      builder: (context, value, child) {
        return visualizerWidget!;
      },
    );
  }
}

/// Simple widget that uses the [Ticker] to update the audio data.
class SamplerTickerUpdater extends StatefulWidget {
  ///
  const SamplerTickerUpdater({
    required this.child,
    super.key,
  });

  /// The child widget.
  final Widget child;

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
    return SizedBox.expand(
      key: UniqueKey(),
      child: widget.child,
    );
  }
}
