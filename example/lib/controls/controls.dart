import 'package:audio_flux/audio_flux.dart';
import 'package:example/controls/common_controls.dart';
import 'package:example/controls/fft_controls.dart';
import 'package:example/controls/fft_painter_controls.dart';
import 'package:example/controls/flux_type_controls.dart';
import 'package:example/controls/shader_controls.dart';
import 'package:example/controls/wave_controls.dart';
import 'package:example/model/model.dart';
import 'package:flutter/material.dart';

class Controls extends StatefulWidget {
  const Controls({
    required this.model,
    super.key,
  });

  final AudioVisualizerModel model;

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height - 450,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FluxTypeControls(
              model: widget.model,
              onChanged: () => setState(() {}),
            ),
            CommonControls(model: widget.model),
            if (widget.model.fluxType == FluxType.fft ||
                widget.model.fluxType == FluxType.shader)
              ColoredBox(
                color: const Color.fromARGB(255, 50, 20, 20),
                child: FftControls(model: widget.model),
              ),
            if (widget.model.fluxType == FluxType.fft)
              ColoredBox(
                color: const Color.fromARGB(255, 20, 20, 40),
                child: ListenableBuilder(
                  listenable: widget.model,
                  builder: (BuildContext context, Widget? child) {
                    return FftPainterControls(model: widget.model);
                  },
                ),
              ),
            if (widget.model.fluxType == FluxType.waveform)
              ColoredBox(
                color: const Color.fromARGB(255, 20, 40, 20),
                child: WaveControls(model: widget.model),
              ),
            if (widget.model.fluxType == FluxType.shader)
              ColoredBox(
                color: const Color.fromARGB(255, 40, 40, 20),
                child: ShaderControls(model: widget.model),
              ),
          ],
        ),
      ),
    );
  }
}
