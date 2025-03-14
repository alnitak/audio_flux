// ignore_for_file: unnecessary_string_interpolations

import 'dart:async' show Completer;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' as ui;

import 'package:audio_flux/audio_flux.dart';
import 'package:audio_flux/src/utils/bmp_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart' show AudioData;
import 'package:shader_buffers/shader_buffers.dart';

class Shader extends StatefulWidget {
  const Shader({
    super.key,
    required this.dataCallback,
    required this.audioData,
    required this.params,
  });

  final DataCallback dataCallback;
  final AudioData? audioData;
  final ModelParams params;

  @override
  State<Shader> createState() => _ShaderState();
}

class _ShaderState extends State<Shader> with SingleTickerProviderStateMixin {
  late final Ticker ticker;
  late Bmp32Header linearData;
  LayerBuffer? mainImage;
  IChannel? iChannel;
  late ShaderController shaderController;

  late int cols;
  String? currentShaderPath;

  @override
  void initState() {
    super.initState();

    cols = (widget.params.fftParams.maxBinIndex -
                widget.params.fftParams.minBinIndex)
            .toInt() +
        1;
    linearData = Bmp32Header.setHeader(cols, 2);

    shaderController = ShaderController();
    currentShaderPath = widget.params.shaderParams.shaderPath;
    mainImage = LayerBuffer(
      shaderAssetsName: widget.params.shaderParams.shaderPath,
    );

    ticker = createTicker((_) {
      buildImageForLinear();
    });

    buildImageForLinear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cols = (widget.params.fftParams.maxBinIndex -
                widget.params.fftParams.minBinIndex)
            .toInt() +
        1;
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  Uint8List createBmpFromAudioData() {
    widget.audioData?.updateSamples();
    var data = widget.dataCallback();
    if (data.length < 512) return Uint8List(0);

    final int maxBinIndex = widget.params.fftParams.maxBinIndex.toInt();
    final int minBinIndex = widget.params.fftParams.minBinIndex.toInt();
    final int newCols = maxBinIndex - minBinIndex + 1;
    if (newCols != cols) {
      cols = newCols;
      linearData = Bmp32Header.setHeader(cols, 2);
    }
    final img = Uint8List(cols * 2 * 4);
    for (var x = 0; x < cols; x++) {
      // fill FFT values
      final fft =
          ((data[x + minBinIndex] * widget.params.audioScale).clamp(0.0, 1.0) *
                  255)
              .toInt();
      img[x * 4] = fft; // R
      img[x * 4 + 1] = 0; // G
      img[x * 4 + 2] = 0; // B
      img[x * 4 + 3] = 255; // A

      // fill wave values
      final wave = ((((data[x + minBinIndex + 256] * widget.params.audioScale)
                          .clamp(-1.0, 1.0) +
                      1.0) /
                  2.0) *
              128)
          .toInt();
      img[x * 4 + cols * 4] = wave;
      img[x * 4 + cols * 4 + 1] = 0; // G
      img[x * 4 + cols * 4 + 2] = 0; // B
      img[x * 4 + cols * 4 + 3] = 255; // A
    }
    return linearData.storeBitmap(img);
  }

  /// Build an image to be passed to the shader.
  /// The image is a matrix of 256x2 RGBA pixels representing:
  /// in the 1st row the frequencies data
  /// in the 2nd row the wave data
  Future<ui.Image?> buildImageForLinear() async {
    final completer = Completer<ui.Image>();
    final data = createBmpFromAudioData();
    if (data.isEmpty) return null;

    ui.decodeImageFromList(data, completer.complete);

    final ret = await completer.future;
    if (iChannel == null) {
      iChannel = IChannel(texture: ret);
      mainImage!.setChannels([iChannel!]);
    } else {
      iChannel!.updateTexture(ret);
    }
    List<Uniform> uniforms = [];
    for (var i = 0; i < (widget.params.shaderParams.params?.length ?? 0); i++) {
      uniforms.add(Uniform(
        name: widget.params.shaderParams.params![i].label,
        value: widget.params.shaderParams.params![i].value,
        defaultValue: widget.params.shaderParams.params![i].value,
        range: RangeValues(
          widget.params.shaderParams.params![i].min,
          widget.params.shaderParams.params![i].max,
        ),
      ));
    }
    mainImage!.uniforms = Uniforms(uniforms);

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    if (mainImage == null) return SizedBox.shrink();

    /// The shader path has changed
    if (currentShaderPath != widget.params.shaderParams.shaderPath) {
      ticker.stop();
      currentShaderPath = widget.params.shaderParams.shaderPath;
      iChannel = null;
      mainImage = LayerBuffer(
        shaderAssetsName: widget.params.shaderParams.shaderPath,
      );
      buildImageForLinear();
    }

    return ShaderBuffers(
        key: ValueKey(currentShaderPath),
        mainImage: mainImage!,
        controller: shaderController,
        onShaderLoaded: (isLoaded) {
          if (isLoaded && !ticker.isActive) ticker.start();
        });
  }
}
