import 'dart:typed_data' show Float32List;

import 'package:flutter/material.dart';

import 'package:audio_flux/src/audio_flux.dart';
import 'package:audio_flux/src/waveform/wave_data_manager.dart';

class WaveformParams {
  const WaveformParams({
    this.backgroundColor = Colors.black,
    this.backgroundGradient,
    this.barColor = Colors.yellow,
    this.barGradient,
    this.barSize = 1,
    this.barSpacing = 0,
    this.chunkSize = 1,
    this.audioScale = 1,
  }) : assert(chunkSize > 0 && chunkSize <= 256,
            'chunkSize must be between 1 and 256');

  /// The background color of the waveform.
  final Color backgroundColor;

  /// The color of the waveform bars.
  final Color barColor;

  /// The gradient of the waveform background. If provided, this will
  /// override [backgroundColor].
  final Gradient? backgroundGradient;

  /// The gradient of the waveform bars. If provided, this will
  /// override [barColor].
  final Gradient? barGradient;

  /// The size of a bar in pixels.
  final int barSize;

  /// The size of spacing between bars in pixels.
  final int barSpacing;

  /// The number of new data to average and add to the waveform.
  /// The higher the number, the smoother the waveform.
  /// This should be >= 1.
  final int chunkSize;

  /// The scale of the audio data. This is used to scale the bars height.
  /// This should be > 0.
  final double audioScale;
}

class Waveform extends StatelessWidget {
  const Waveform({
    super.key,
    required this.dataCallback,
    this.params = const WaveformParams(),
  });

  final DataCallback dataCallback;
  final WaveformParams params;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: WavePainter(
          getDataCallback: dataCallback,
          params: params,
        ),
      ),
    );
  }
}

/// Custom painter to draw the wave data.
class WavePainter extends CustomPainter {
  WavePainter({
    required this.getDataCallback,
    required this.params,
  });

  final DataCallback getDataCallback;
  final WaveformParams params;

  void processWaveData(Float32List currentWaveData) {
    final waveManager = WaveDataManager.instance;
    // if (!waveManager.hasDataChanged(currentWaveData)) return;

    final buffer = waveManager.data;

    final chunkSize = params.chunkSize;
    var processedLength = currentWaveData.length ~/ chunkSize;
    // if (processedLength == 0) processedLength = 2;

    // Shift existing data to the left
    for (var i = 0; i < buffer.length - processedLength; i++) {
      buffer[i] = buffer[i + processedLength];
    }

    // Process data in chunks and store at the end
    for (var i = 0; i < processedLength; i++) {
      var sum = 0.0;
      final startIdx = i * chunkSize;

      // Calculate average for this chunk
      for (var j = 0;
          j < chunkSize && (startIdx + j) < currentWaveData.length;
          j++) {
        sum += currentWaveData[startIdx + j];
        // print('sum $i $j : ${sum.toStringAsFixed(2)}');
      }

      // Store at the end of the array
      buffer[buffer.length - processedLength + i] = sum / chunkSize;
    }
  }

  int _calculateEffectiveBarCount(double width) {
    return (width / (params.barSize + params.barSpacing)).floor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveBarCount = _calculateEffectiveBarCount(size.width);

    final waveManager = WaveDataManager.instance;
    waveManager.ensureCapacity(effectiveBarCount);

    var currentWaveData = getDataCallback();
    if (currentWaveData.isNotEmpty) {
      processWaveData(currentWaveData);
    }

    // Draw the background
    final backgroundPaint = Paint();
    if (params.backgroundGradient != null) {
      backgroundPaint.shader = params.backgroundGradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      backgroundPaint.color = params.backgroundColor;
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    final paint = Paint();

    // Set up the bar paint
    if (params.barGradient != null) {
      paint.shader = params.barGradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = params.barColor;
    }

    // Draw the bars
    final barWidth =
        params.barSize.toDouble() + params.barSpacing;
    for (var i = 0; i < effectiveBarCount; i++) {
      final value = waveManager.data[i];
      final barHeight = size.height * value * params.audioScale;
      final barX = i * barWidth;

      canvas.drawRect(
        Rect.fromLTWH(
          barX,
          (size.height - barHeight) / 2,
          params.barSize.toDouble(),
          barHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return true;
  }
}
