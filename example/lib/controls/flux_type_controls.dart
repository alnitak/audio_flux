import 'package:example/model/model.dart';
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
    //
    return Wrap(
      runSpacing: 12,
      spacing: 22,
      children: [
        for (var i = 0; i < FluxType.values.length; i++)
          FluxCheckBox(
            label: FluxType.values[i].name,
            value: widget.model.fluxType.index == i,
            onChanged: (value) {
              widget.model.updateFluxType(type: FluxType.values[i]);
              widget.onChanged();
            },
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
        Text(label),
        Checkbox.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
