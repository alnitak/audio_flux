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
              widget.model.fftParams.minBinIndex.toDouble(),
              widget.model.fftParams.maxBinIndex.toDouble(),
            ),
            onChanged: (value) {
              widget.model.updateFftParams(
                minBinIndex: value.start.toInt(),
                maxBinIndex: value.end.toInt(),
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
