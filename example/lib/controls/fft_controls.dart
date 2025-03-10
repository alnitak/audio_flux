import 'package:example/controls/sliders.dart';
import 'package:example/model/model.dart';
import 'package:flutter/material.dart';

class FftControls extends StatefulWidget {
  const FftControls({
    super.key,
    required this.model,
  });

  final AudioVisualizerModel model;

  @override
  State<FftControls> createState() => _FftControlsState();
}

class _FftControlsState extends State<FftControls> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SliderParam(
            label: 'fftSmoothing',
            min: 0.0,
            max: 1.0,
            value: widget.model.fftParams.fftSmoothing,
            onChanged: (value) {
              widget.model.updateFftParams(fftSmoothing: value);
              setState(() {});
            },
          ),
          RangeSliderParam(
            label: 'min max bins',
            min: 0,
            max: 255,
            values: RangeValues(
              widget.model.fftParams.minIndex.toDouble(),
              widget.model.fftParams.maxIndex.toDouble(),
            ),
            onChanged: (value) {
              widget.model.updateFftParams(
                minIndex: value.start.toInt(),
                maxIndex: value.end.toInt(),
              );
              setState(() {});
            },
          ),
          SliderParam(
            label: 'barSpacingScale',
            min: 0.0,
            max: 1.0,
            value: widget.model.fftParams.barSpacingScale,
            onChanged: (value) {
              widget.model.updateFftParams(barSpacingScale: value);
              setState(() {});
            },
          ),
          SliderParam(
            label: 'shrinkTo',
            min: -1.0,
            max: widget.model.fftParams.maxIndex.toDouble(),
            value: widget.model.fftParams.shrinkTo.toDouble() - 1,
            onChanged: (value) {
              if (value < 0) value = -1;
              widget.model.updateFftParams(shrinkTo: value.toInt());
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
