import 'dart:developer' as dev;

import 'package:audio_flux/audio_flux.dart';
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

  var dataSource = ValueNotifier<DataSources?>(null);
  var fluxType = ValueNotifier<FluxType>(FluxType.waveform);

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
        await soloud.loadAsset('assets/ElectroNebulae.mp3'),
        looping: true,
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    setState(() {});
  }

  Future<void> initRecorder() async {
    try {
      soloud.deinit();

      /// [PCMFormat.f32le] is required for getting audio data to work.
      await recorder.init(format: PCMFormat.f32le);
      recorder.start();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
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
                      recorder.deinit();
                      await initSoLoud();
                      dataSource.value = DataSources.soloud;
                    },
                    child: Text('start SoLoud'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      soloud.deinit();
                      await initRecorder();
                      dataSource.value = DataSources.recorder;
                    },
                    child: Text('start Recorder'),
                  ),
                ],
              ),
              ValueListenableBuilder<FluxType>(
                valueListenable: fluxType,
                builder: (context, flux, snapshot) {
                  return ValueListenableBuilder<DataSources?>(
                    valueListenable: dataSource,
                    builder: (context, data, snapshot) {
                      if (data == null) {
                        return SizedBox.shrink();
                      }
                      return SizedBox(
                        width: 300,
                        height: 100,
                        child: AudioFlux(
                          fluxType: flux,
                          dataSource: data,
                          waveformParams: const WaveformParams(
                            barSize: 1,
                            barSpacing: 0,
                            chunkSize: 256,
                            audioScale: 2,
                            backgroundColor: Colors.black,
                            backgroundGradient: LinearGradient(
                              colors: [
                                Colors.indigo,
                                Colors.pink,
                                Colors.black,
                              ],
                              stops: [0.0, 0.5, 0.55],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            barColor: Colors.redAccent,
                            barGradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 200, 0, 0),
                                Colors.yellow,
                                Color.fromARGB(255, 0, 200, 0),
                                Colors.yellow,
                                Color.fromARGB(255, 200, 0, 0),
                              ],
                              stops: [0.0, 0.35, 0.5, 0.65, 1.0],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      );
                    },
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
