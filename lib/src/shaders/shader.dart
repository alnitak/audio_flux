import 'dart:async' show Completer;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' as ui;

import 'package:audio_flux/audio_flux.dart';
import 'package:audio_flux/src/utils/bmp_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart' show AudioData;
import 'package:shader_buffers/shader_buffers.dart';

/// The shader widget which paints a given custom shader.
/// It will look at the `params.shaderParams` to get the [ShaderParams].
class Shader extends StatefulWidget {
  ///
  const Shader({
    required this.dataCallback,
    required this.audioData,
    required this.params,
    super.key,
  });

  /// The callback to get the wave and FFT data.
  final DataCallback dataCallback;

  /// The audio data.
  final AudioData? audioData;

  /// The model parameters.
  final ModelParams params;

  @override
  State<Shader> createState() => _ShaderState();
}

class _ShaderState extends State<Shader> with SingleTickerProviderStateMixin {
  late final Ticker ticker;
  late Bmp32Header linearData;
  LayerBuffer? mainImage;
  IChannel? iChannelAudio;
  late ShaderController shaderController;

  late int cols;
  String? currentShaderPath;

  @override
  void initState() {
    super.initState();

    cols = (widget.params.fftParams.maxBinIndex -
            widget.params.fftParams.minBinIndex) +
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

  /// Use to chatch changes in dependencies usually triggered by a reload.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cols = (widget.params.fftParams.maxBinIndex -
            widget.params.fftParams.minBinIndex) +
        1;
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  /// Create the texture to pass to the shader. The texture is a matrix of 256x2
  /// RGBA pixels representing:
  /// in the 1st row the frequencies data
  /// in the 2nd row the wave data
  Uint8List createBmpFromAudioData() {
    widget.audioData?.updateSamples();
    final data = widget.dataCallback();
    if (data.length < 512) return Uint8List(0);

    final maxBinIndex = widget.params.fftParams.maxBinIndex;
    final minBinIndex = widget.params.fftParams.minBinIndex;
    final newCols = maxBinIndex - minBinIndex + 1;
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
              255)
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

    /// Create the iChannel if not already
    final ret = await completer.future;
    if (iChannelAudio == null) {
      iChannelAudio = IChannel(texture: ret);
      mainImage!.setChannels(
        [
          iChannelAudio!,
          if (widget.params.shaderParams.textureChannels != null &&
              widget.params.shaderParams.textureChannels!.isNotEmpty)
            ...widget.params.shaderParams.textureChannels!,
        ],
      );
    } else {
      iChannelAudio!.updateTexture(ret);
    }

    /// add the uniforms
    final uniforms = <Uniform>[];
    for (var i = 0; i < (widget.params.shaderParams.params?.length ?? 0); i++) {
      uniforms.add(
        Uniform(
          name: widget.params.shaderParams.params![i].label,
          value: widget.params.shaderParams.params![i].value,
          defaultValue: widget.params.shaderParams.params![i].value,
          range: RangeValues(
            widget.params.shaderParams.params![i].min,
            widget.params.shaderParams.params![i].max,
          ),
        ),
      );
    }
    mainImage!.uniforms = Uniforms(uniforms);

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    if (mainImage == null) return const SizedBox.shrink();

    /// The shader path has changed
    if (currentShaderPath != widget.params.shaderParams.shaderPath) {
      ticker.stop();
      currentShaderPath = widget.params.shaderParams.shaderPath;
      iChannelAudio = null;
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
      },
    );
  }
}
