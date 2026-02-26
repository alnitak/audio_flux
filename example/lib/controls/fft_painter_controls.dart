import 'package:example/controls/sliders.dart';
import 'package:example/model/model.dart';
import 'package:flutter/material.dart';

class FftPainterControls extends StatefulWidget {
  const FftPainterControls({
    required this.model,
    super.key,
  });

  final AudioVisualizerModel model;

  @override
  State<FftPainterControls> createState() => _FftPainterControlsState();
}

class _FftPainterControlsState extends State<FftPainterControls> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SliderParam(
            label: 'barSpacingScale',
            min: 0,
            max: 1,
            value: widget.model.fftPainterParams.barSpacingScale,
            onChanged: (value) {
              widget.model.updateFftPainterParams(barSpacingScale: value);
              setState(() {});
            },
          ),
          SliderParam(
            label: 'barRadius',
            min: 0,
            max: 6,
            value: widget.model.fftPainterParams.barRadius,
            onChanged: (value) {
              widget.model.updateFftPainterParams(barRadius: value);
              setState(() {});
            },
          ),
          SliderParam(
            label: 'shrinkTo',
            min: 2,
            max: widget.model.fftParams.maxBinIndex.toDouble() + 1,
            value: widget.model.fftPainterParams.shrinkTo.toDouble(),
            onChanged: (value) {
              var newValue = value;
              if (newValue <= 0) newValue = -1;
              if (newValue >
                  widget.model.fftParams.maxBinIndex -
                      widget.model.fftParams.minBinIndex) {
                newValue = widget.model.fftParams.maxBinIndex -
                    widget.model.fftParams.minBinIndex +
                    1;
              }
              widget.model.updateFftPainterParams(shrinkTo: newValue.toInt());
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
