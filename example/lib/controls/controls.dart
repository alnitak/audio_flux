import 'package:audio_flux/audio_flux.dart';
import 'package:example/controls/common_controls.dart';
import 'package:example/controls/fft_controls.dart';
import 'package:example/controls/flux_type_controls.dart';
import 'package:example/controls/wave_controls.dart';
import 'package:example/model/model.dart';
import 'package:flutter/material.dart';

class Controls extends StatefulWidget {
  const Controls({
    super.key,
    required this.model,
  });

  final AudioVisualizerModel model;

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FluxTypeControls(
          model: widget.model,
          onChanged: () => setState(() {}),
        ),
        CommonControls(model: widget.model),
        if (widget.model.fluxType == FluxType.fft)
          ColoredBox(
            color: Color.fromARGB(255, 20, 20, 20),
            child: FftControls(model: widget.model),
          ),
        if (widget.model.fluxType == FluxType.waveform)
          ColoredBox(
            color: Color.fromARGB(255, 20, 20, 20),
            child: WaveControls(model: widget.model),
          ),
      ],
    );
  }
}
