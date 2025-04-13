// ignore_for_file: public_member_api_docs

import 'dart:developer' as dev;

import 'package:audio_flux/audio_flux.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

/// Please see at `main_extended.dart` for a more in depth example.
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
  final soloud = SoLoud.instance;

  @override
  void initState() {
    super.initState();

    initSoLoud('assets/audio/ElectroNebulae.mp3');
  }

  @override
  void dispose() {
    soloud.deinit();
    super.dispose();
  }

  Future<void> initSoLoud(String audioAsset) async {
    try {
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AudioFlux(
          fluxType: FluxType.shader,
          dataSource: DataSources.soloud,
          modelParams: ModelParams(
            shaderParams: ShaderParams(
              shaderPath: 'assets/shaders/texture.frag',
              textureChannels: [
                TextureChannel(assetsTexturePath: 'assets/dash.png'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
