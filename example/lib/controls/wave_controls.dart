import 'package:example/controls/sliders.dart';
import 'package:example/model/model.dart';
import 'package:flutter/material.dart';

class WaveControls extends StatefulWidget {
  const WaveControls({
    required this.model,
    super.key,
  });

  final AudioVisualizerModel model;

  @override
  State<WaveControls> createState() => _WaveControlsState();
}

class _WaveControlsState extends State<WaveControls> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SliderParam(
            label: 'barsWidth',
            min: 1,
            max: 30,
            value: widget.model.waveformParams.barsWidth.toDouble(),
            onChanged: (value) {
              widget.model
                  .updateWaveformPainterParams(barsWidth: value.toInt());
              setState(() {});
            },
          ),
          SliderParam(
            label: 'barSpacingScale',
            min: 0,
            max: 1,
            value: widget.model.waveformParams.barSpacingScale,
            onChanged: (value) {
              widget.model.updateWaveformPainterParams(barSpacingScale: value);
              setState(() {});
            },
          ),
          SliderParam(
            label: 'barRadius',
            min: 0,
            max: 6,
            value: widget.model.waveformParams.barRadius,
            onChanged: (value) {
              widget.model.updateWaveformPainterParams(barRadius: value);
              setState(() {});
            },
          ),
          SliderParam(
            label: 'chunkSize',
            min: 1,
            max: 256,
            value: widget.model.waveformParams.chunkSize.toDouble(),
            onChanged: (value) {
              widget.model
                  .updateWaveformPainterParams(chunkSize: value.toInt());
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
