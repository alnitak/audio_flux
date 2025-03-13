import 'package:example/controls/sliders.dart';
import 'package:example/model/model.dart';
import 'package:flutter/material.dart';

class FftPainterControls extends StatefulWidget {
  const FftPainterControls({
    super.key,
    required this.model,
  });

  final AudioVisualizerModel model;

  @override
  State<FftPainterControls> createState() => _FftPainterControlsState();
}

class _FftPainterControlsState extends State<FftPainterControls> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SliderParam(
            label: 'barSpacingScale',
            min: 0.0,
            max: 1.0,
            value: widget.model.fftPainterParams.barSpacingScale,
            onChanged: (value) {
              widget.model.updateFftPainterParams(barSpacingScale: value);
              setState(() {});
            },
          ),
          SliderParam(
            label: 'shrinkTo',
            min: -1.0,
            max: widget.model.fftParams.maxBinIndex.toDouble(),
            value: widget.model.fftPainterParams.shrinkTo.toDouble() - 1,
            onChanged: (value) {
              if (value < 0) value = -1;
              if (value >
                  widget.model.fftParams.maxBinIndex -
                      widget.model.fftParams.minBinIndex) {
                value = widget.model.fftParams.maxBinIndex -
                      widget.model.fftParams.minBinIndex +1;
              }
              widget.model.updateFftPainterParams(shrinkTo: value.toInt());
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
