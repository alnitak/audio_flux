import 'dart:typed_data' show Float32List;

import 'package:audio_flux/src/utils/painter_params.dart';
import 'package:flutter/material.dart';
import 'package:audio_flux/src/audio_flux.dart';

class Fft extends StatelessWidget {
  const Fft({
    super.key,
    required this.dataCallback,
    required this.params,
  });

  final DataCallback dataCallback;
  final PainterParams params;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: FftPainter(
          getDataCallback: dataCallback,
          params: params,
        ),
      ),
    );
  }
}

/// Custom painter to draw the wave data.
class FftPainter extends CustomPainter {
  FftPainter({
    required this.getDataCallback,
    required this.params,
  });

  final DataCallback getDataCallback;
  final PainterParams params;

  void processWaveData(Float32List currentWaveData) {
    final buffer = params.dataManager.data;
    final barCount = params.fftParams.shrinkTo;
    final minIndex = params.fftParams.minIndex;
    final maxIndex = params.fftParams.maxIndex;
    final range = maxIndex - minIndex + 1;
    final chunkSize = range / barCount;

    for (var i = 0; i < barCount; i++) {
      var sum = 0.0;
      var count = 0;

      // Calculate chunk boundaries
      final startIdx = (i * chunkSize + minIndex).floor();
      final endIdx = ((i + 1) * chunkSize + minIndex).ceil();

      // Ensure we don't exceed maxIndex
      final effectiveEndIdx = endIdx.clamp(0, maxIndex + 1);

      for (var j = startIdx; j < effectiveEndIdx; j++) {
        sum += currentWaveData[j];
        count++;
      }

      // Store the average for this chunk
      buffer[i] = count > 0 ? sum / count : 0.0;
    }
  }

  int _calculateEffectiveBarCount() {
    return params.fftParams.maxIndex - params.fftParams.minIndex + 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveBarCount = _calculateEffectiveBarCount();

    params.dataManager.ensureCapacity(effectiveBarCount);

    var currentFftData = getDataCallback();
    if (currentFftData.isNotEmpty) {
      processWaveData(currentFftData);
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
    final barCount = params.fftParams.shrinkTo - 1;
    final barWidth = size.width / barCount;
    for (var i = 0; i < barCount; i++) {
      final value = params.dataManager.data[i];
      final barHeight = size.height * value * params.audioScale;
      final barX = i * barWidth;

      canvas.drawRect(
        Rect.fromLTWH(
          barX,
          // (size.height - barHeight) / 2,
          size.height - barHeight,
          barWidth * params.fftParams.barSpacingScale,
          barHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FftPainter oldDelegate) {
    return true;
  }
}
