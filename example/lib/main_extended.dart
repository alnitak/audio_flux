// ignore_for_file: public_member_api_docs

import 'dart:developer' as dev;

import 'package:audio_flux/audio_flux.dart';
import 'package:example/controls/controls.dart';
import 'package:example/model/model.dart';
import 'package:example/shaders/shaders.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final recorder = Recorder.instance;
  final soloud = SoLoud.instance;

  final AudioVisualizerModel model = AudioVisualizerModel();

  late Gradient backgroundGradient;
  late Gradient waveBarGradient;
  late Gradient fftBarGradient;

  @override
  void initState() {
    super.initState();

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      Permission.microphone.request().isGranted.then((value) async {
        if (!value) {
          await [Permission.microphone].request();
        }
      });
    }

    setupModel();
    initSoLoud('assets/audio/chunk_mfn.mp3');
  }

  @override
  void reassemble() {
    super.reassemble();
    setupModel();
  }

  void setupModel() {
    /// setup the default parameters
    model

      /// set default maxBinIndex for fft to have a better visualization
      ..updateFftParams(fftSmoothing: 0.92, maxBinIndex: 180)

      /// use flutter_soloud as the audio source
      ..updateDataSource(source: DataSources.soloud)

      /// use shader
      ..updateFluxType(type: FluxType.shader)

      /// use the 8th shader in the [Shaders] list
      ..updateShaderParams(
        shaderName: Shaders.shaderParams[9].shaderName,
        shaderPath: Shaders.shaderParams[9].shaderPath,
        params: Shaders.shaderParams[9].params,
        paramsRange: Shaders.shaderParams[9].paramsRange,
        textureChannels: Shaders.shaderParams[9].textureChannels,
      )

      /// set default gradients
      ..updateModelParams(
        backgroundGradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 7, 28, 148),
            Color.fromARGB(255, 183, 23, 76),
            Colors.black,
            Color.fromARGB(255, 98, 65, 57),
          ],
          stops: [0.0, 0.5, 0.55, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        barGradient: model.fluxType == FluxType.waveform
            ? const LinearGradient(
                colors: [
                  Color.fromARGB(255, 200, 0, 0),
                  Color.fromARGB(255, 253, 233, 58),
                  Color.fromARGB(255, 0, 200, 0),
                  Colors.black,
                  Color.fromARGB(255, 0, 200, 0),
                  Color.fromARGB(255, 253, 233, 58),
                  Color.fromARGB(255, 200, 0, 0),
                ],
                stops: [0.0, 0.4, 0.495, 0.5, 0.505, 0.6, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [
                  Color.fromARGB(255, 200, 0, 0),
                  Color.fromARGB(255, 253, 233, 58),
                  Color.fromARGB(255, 0, 200, 0),
                ],
                stops: [0, 0.6, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      );
  }

  @override
  void dispose() {
    soloud.deinit();
    recorder.deinit();
    super.dispose();
  }

  Future<void> initSoLoud(String audioAsset) async {
    try {
      recorder.deinit();
      await soloud.init(bufferSize: 1024, channels: Channels.mono);
      soloud.setVisualizationEnabled(true);

      await soloud.play(
        await soloud.loadAsset(
          audioAsset,
          mode: LoadMode.disk,
        ),
        looping: true,
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    model.updateDataSource(source: DataSources.soloud);
  }

  Future<void> initRecorder() async {
    try {
      soloud.deinit();

      /// [PCMFormat.f32le] is required for getting audio data to work.
      await recorder.init(
        sampleRate: 44100,
        format: PCMFormat.f32le,
      );
      recorder.start();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    model.updateDataSource(source: DataSources.recorder);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
        ).copyWith(surface: const Color.fromARGB(255, 0, 30, 0)),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.black,
          constraints: BoxConstraints(),
        ),
      ),
      home: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(0.9)),
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            bottomSheet: Padding(
              padding: const EdgeInsets.all(6),
              child: Controls(model: model),
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: Column(
                spacing: 16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 16,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await initSoLoud('assets/audio/ElectroNebulae.mp3');
                        },
                        child: const Text('electro'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await initSoLoud('assets/audio/chunk_mfn.mp3');
                        },
                        child: const Text('song'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await initSoLoud('assets/audio/audiocheck.wav');
                        },
                        child: const Text('sweep'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await initRecorder();
                        },
                        child: const Text('recorder'),
                      ),
                    ],
                  ),
                  ListenableBuilder(
                    listenable: model,
                    builder: (BuildContext context, Widget? child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: AudioFlux(
                          fluxType: model.fluxType,
                          dataSource: model.dataSource,
                          modelParams: model.modelParams,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
