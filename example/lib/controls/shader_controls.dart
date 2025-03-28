import 'package:audio_flux/audio_flux.dart';
import 'package:example/controls/sliders.dart';
import 'package:example/model/model.dart';
import 'package:flutter/material.dart';

class ShaderControls extends StatefulWidget {
  const ShaderControls({
    required this.model,
    super.key,
  });
  final AudioVisualizerModel model;

  @override
  State<ShaderControls> createState() => _ShaderControlsState();
}

class _ShaderControlsState extends State<ShaderControls> {
  @override
  Widget build(BuildContext context) {
    final sp = widget.model.shaderParams;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sp.shaderName),
          for (var i = 0; i < (sp.params?.length ?? 0); i++)
            SliderParam(
              label: sp.params![i].label,
              min: sp.params![i].min,
              max: sp.params![i].max,
              value: sp.params![i].value,
              onChanged: (value) {
                final newParams = List<ShaderParam>.from(sp.params!);
                newParams[i] = newParams[i].copyWith(value: value);
                widget.model.updateShaderParams(
                  params: newParams,
                );
                setState(() {});
              },
            ),
          for (var i = 0; i < (sp.paramsRange?.length ?? 0); i++)
            RangeSliderParam(
              label: sp.paramsRange![i].label,
              min: sp.paramsRange![i].min,
              max: sp.paramsRange![i].max,
              values: RangeValues(
                sp.paramsRange![i].minValue,
                sp.paramsRange![i].maxValue,
              ),
              onChanged: (value) {
                final newParams = List<ShaderParamRange>.from(sp.paramsRange!);
                newParams[i] = newParams[i].copyWith(
                  minValue: value.start,
                  maxValue: value.end,
                );
                widget.model.updateShaderParams(
                  paramsRange: newParams,
                );
                setState(() {});
              },
            ),
        ],
      ),
    );
  }
}
