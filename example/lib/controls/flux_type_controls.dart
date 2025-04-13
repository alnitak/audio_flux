import 'package:audio_flux/audio_flux.dart';
import 'package:example/model/model.dart';
import 'package:example/shaders/shaders.dart';
import 'package:flutter/material.dart';

class FluxTypeControls extends StatefulWidget {
  const FluxTypeControls({
    required this.model,
    required this.onChanged,
    super.key,
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
              if (FluxType.values[i] != FluxType.shader)
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
                    textureChannels: Shaders.shaderParams[i].textureChannels,
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
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
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
