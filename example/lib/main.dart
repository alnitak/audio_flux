import 'dart:developer' as dev;

import 'package:audio_flux/audio_flux.dart';
import 'package:example/controls/controls.dart';
import 'package:example/model/model.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

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

  runApp(MainApp());
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
    setupGradients();

    initSoLoud();
  }

  @override
  void reassemble() {
    super.reassemble();
    setupGradients();
  }

  void setupGradients() {
    model.updateModelParams(
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
              ));
  }

  @override
  void dispose() {
    soloud.deinit();
    recorder.deinit();
    super.dispose();
  }

  Future<void> initSoLoud() async {
    try {
      recorder.deinit();
      await soloud.init(bufferSize: 2048);
      soloud.setVisualizationEnabled(true);
      await soloud.play(
        await soloud.loadAsset('assets/audio/ElectroNebulae.mp3'),
        looping: true,
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    model.updateDataSource(source: DataSources.soloud);
  }

  Future<void> initSoLoud2() async {
    try {
      recorder.deinit();
      await soloud.init(bufferSize: 2048);
      soloud.setVisualizationEnabled(true);
      await soloud.play(
        await soloud.loadAsset('assets/audio/audiocheck.wav'),
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
        channels: RecorderChannels.mono,
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
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        bottomSheet: Controls(model: model),
        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: 16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await initSoLoud();
                    },
                    child: Text('SoLoud song'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await initSoLoud2();
                    },
                    child: Text('SoLoud audio sweep'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await initRecorder();
                    },
                    child: Text('start Recorder'),
                  ),
                ],
              ),
              ListenableBuilder(
                listenable: model,
                builder: (BuildContext context, Widget? child) {
                  return AudioFlux(
                    fluxType: model.fluxType,
                    dataSource: model.dataSource,
                    modelParams: model.modelParams,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
