import 'dart:typed_data' show Float32List;

import 'package:audio_flux/src/audio_flux.dart';
import 'package:audio_flux/src/params/model_params.dart';
import 'package:flutter/material.dart';

/// Widget to draw the FFT data.
class Fft extends StatelessWidget {
  /// Constructor.
  const Fft({
    required this.dataCallback,
    required this.params,
    super.key,
  });

  /// The callback to get the FFT data.
  final DataCallback dataCallback;

  /// The model parameters.
  final ModelParams params;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        size: Size.infinite,
        painter: FftPainter(
          dataCallback: dataCallback,
          params: params,
        ),
      ),
    );
  }
}

/// Custom painter to draw the FFT data.
class FftPainter extends CustomPainter {
  ///
  FftPainter({
    required this.dataCallback,
    required this.params,
  }) {
    // Sanitize the shrinkTo value
    final min = params.fftParams.minBinIndex;
    final max = params.fftParams.maxBinIndex;
    final maxBars = (max - min + 1).clamp(1, 256);
    final requestedShrinkTo = params.fftPainterParams.shrinkTo;
    _shrinkTo = (requestedShrinkTo <= maxBars ? requestedShrinkTo : maxBars)
        .clamp(1, 256);
  }

  /// The callback to get the FFT data.
  final DataCallback dataCallback;

  /// The model parameters.
  final ModelParams params;

  /// Sanitized "params.fftPainterParams.shrinkTo" value.
  /// This is used to calculate the number of bars to draw and must not exceed
  /// "params.fftParams.maxBinIndex - params.fftParams.minBinIndex + 1".
  late int _shrinkTo;

  /// Process the wave data and store it in the buffer.
  ///
  /// This is an O(n) operation, where n is the length of the wave data.
  ///
  /// The buffer is divided into `barCount` chunks, and for each chunk the
  /// average of the wave data is calculated and stored in the buffer.
  ///
  /// The average is calculated by summing all the values in the chunk and
  /// dividing by the number of values in the chunk. If a chunk has no values
  /// (i.e. the chunk size is 0), the average is set to 0.0.
  ///
  /// The boundaries of the chunk are calculated by multiplying the chunk count
  /// by the chunk size and adding the `minBinIndex` and `maxBinIndex` to the
  /// start and end of the chunk respectively. The clamp function is used to
  /// ensure that the end index does not exceed the `maxBinIndex`.
  void processWaveData(Float32List currentWaveData) {
    final buffer = params.dataManager.data;
    final barCount = _shrinkTo;
    final minBinIndex = params.fftParams.minBinIndex;
    final maxBinIndex = params.fftParams.maxBinIndex;
    final range = (maxBinIndex - minBinIndex + 1).clamp(1, 256);
    final chunkSize = range / barCount;
    final dataLimit = currentWaveData.length;

    for (var i = 0; i < barCount; i++) {
      if (i >= buffer.length) break;
      var sum = 0.0;
      var count = 0;

      // Calculate chunk boundaries
      final startIdx = (i * chunkSize + minBinIndex).floor();
      final endIdx = ((i + 1) * chunkSize + minBinIndex).ceil();

      // Ensure we don't exceed maxIndex or the available data length
      final safeStartIdx = startIdx.clamp(0, dataLimit);
      final effectiveEndIdx =
          endIdx.clamp(0, maxBinIndex + 1).clamp(0, dataLimit);

      for (var j = safeStartIdx; j < effectiveEndIdx; j++) {
        sum += currentWaveData[j];
        count++;
      }

      // Store the average for this chunk
      buffer[i] = count > 0 ? sum / count : 0.0;
    }
  }

  /// Calculates the number of bars to draw in the FFT visualizer.
  int _calculateEffectiveBarCount() {
    final binCount =
        params.fftParams.maxBinIndex - params.fftParams.minBinIndex + 1;
    return _shrinkTo > binCount ? _shrinkTo : binCount;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final effectiveBarCount = _calculateEffectiveBarCount();

    params.dataManager.ensureCapacity(effectiveBarCount);

    final currentFftData = dataCallback();
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
    final barCount = _shrinkTo;
    final barWidth = size.width / barCount;
    final buffer = params.dataManager.data;
    for (var i = 0; i < barCount && i < buffer.length; i++) {
      final value = buffer[i];
      final barHeight = size.height * value * params.audioScale;
      final barX = i * barWidth;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            barX,
            size.height - barHeight,
            barWidth * (1.0 - params.fftPainterParams.barSpacingScale),
            barHeight,
          ),
          Radius.circular(params.fftPainterParams.barRadius),
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
