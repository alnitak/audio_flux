import 'package:example/model/model.dart';
import 'package:example/shaders/shaders.dart';
import 'package:flutter/material.dart';
import 'package:audio_flux/audio_flux.dart';

class FluxTypeControls extends StatefulWidget {
  const FluxTypeControls({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final AudioVisualizerModel model;
  final VoidCallback onChanged;

  @override
  State<FluxTypeControls> createState() => _FluxTypeControlsState();
}

class _FluxTypeControlsState extends State<FluxTypeControls> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          runSpacing: 12,
          spacing: 22,
          children: [
            for (var i = 0; i < FluxType.values.length; i++)
              if (FluxType.values[i].name != 'shader')
                FluxCheckBox(
                  label: FluxType.values[i].name,
                  value: widget.model.fluxType.index == i,
                  onChanged: (value) {
                    widget.model.updateFluxType(type: FluxType.values[i]);
                    widget.onChanged();
                  },
                ),
          ],
        ),
        Wrap(
          runSpacing: 12,
          spacing: 22,
          children: [
            for (var i = 0; i < Shaders.shaderParams.length; i++)
              FluxCheckBox(
                label: Shaders.shaderParams[i].shaderName,
                value: widget.model.fluxType == FluxType.shader &&
                    widget.model.shaderParams.shaderName ==
                        Shaders.shaderParams[i].shaderName,
                onChanged: (value) {
                  widget.model.updateFluxType(type: FluxType.shader);
                  widget.model.updateShaderParams(
                    shaderName: Shaders.shaderParams[i].shaderName,
                    shaderPath: Shaders.shaderParams[i].shaderPath,
                    params: Shaders.shaderParams[i].params,
                    paramsRange: Shaders.shaderParams[i].paramsRange,
                  );
                  widget.onChanged();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class FluxCheckBox extends StatelessWidget {
  const FluxCheckBox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox.adaptive(
          value: value,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }
}
