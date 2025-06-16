import 'dart:typed_data' show Float32List;

import 'package:audio_flux/src/audio_flux.dart';
import 'package:audio_flux/src/params/model_params.dart';
import 'package:flutter/material.dart';

/// Widget to draw the wave data.
class Waveform extends StatelessWidget {
  ///
  const Waveform({
    required this.dataCallback,
    required this.params,
    super.key,
  });

  /// The callback to get the wave data.
  final DataCallback dataCallback;

  /// The model parameters.
  final ModelParams params;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: WavePainter(
          dataCallback: dataCallback,
          params: params,
        ),
      ),
    );
  }
}

/// Custom painter to draw the wave data.
class WavePainter extends CustomPainter {
  ///
  WavePainter({
    required this.dataCallback,
    required this.params,
  });

  /// The callback to get the FFT data.
  final DataCallback dataCallback;

  /// The model parameters.
  final ModelParams params;

  /// Processes the current wave data and updates the buffer.
  ///
  /// This function takes the current wave data and processes it in chunks
  /// defined by the `chunkSize` parameter. The existing data in the buffer
  /// is shifted to the left by the number of processed chunks. Each chunk
  /// is averaged, and the result is stored at the end of the buffer.
  ///
  /// The function operates by first determining the number of full chunks
  /// that can be processed from the `currentWaveData`. It then shifts the
  /// existing buffer data to make room for the new processed values. For each
  /// chunk, the average value is calculated and stored in the buffer.
  ///
  /// If the calculated index for storing the average value is within the
  /// bounds of the buffer, the averaged value is stored at that index.
  ///
  /// [currentWaveData] is the wave data to be processed.
  void processWaveData(Float32List currentWaveData) {
    final buffer = params.dataManager.data;

    final chunkSize = params.waveformParams.chunkSize;
    final processedLength = currentWaveData.length ~/ chunkSize;

    // Shift existing data to the left
    for (var i = 0; i < buffer.length - processedLength; i++) {
      buffer[i] = buffer[i + processedLength];
    }

    // Process data in chunks and store at the end
    for (var i = 0; i < processedLength; i++) {
      var sum = 0.0;
      final startIdx = i * chunkSize;

      // Calculate average for this chunk
      var j = 0;
      for (j = 0;
          j < chunkSize && (startIdx + j) < currentWaveData.length;
          j++) {
        sum += currentWaveData[startIdx + j];
      }

      // Store at the end of the array
      final id = buffer.length - processedLength + i;
      if (id >= 0 && id < buffer.length) {
        buffer[id] = sum / j;
      }
    }
  }

  /// Calculates the effective number of bars that can be drawn
  /// given the current canvas width and the bar width.
  int _calculateEffectiveBarCount(double width) {
    return (width / params.waveformParams.barsWidth).floor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveBarCount = _calculateEffectiveBarCount(size.width);

    params.dataManager.ensureCapacity(effectiveBarCount);

    final currentWaveData = dataCallback();
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
    final barWidth = params.waveformParams.barsWidth.toDouble();
    for (var i = 0; i < effectiveBarCount; i++) {
      final value = params.dataManager.data[i];
      final barHeight = size.height * value * 2 * params.audioScale;
      final barX = i * barWidth;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            barX,
            (size.height - barHeight) * 0.5,
            barWidth * (1.0 - params.waveformParams.barSpacingScale),
            barHeight,
          ),
          Radius.circular(params.waveformParams.barRadius),
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
