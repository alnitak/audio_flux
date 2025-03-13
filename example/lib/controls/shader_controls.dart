import 'package:audio_flux/audio_flux.dart';
import 'package:example/controls/sliders.dart';
import 'package:example/model/model.dart';
import 'package:flutter/material.dart';

class ShaderControls extends StatefulWidget {
  const ShaderControls(
      {super.key, required this.model});
  final AudioVisualizerModel model;

  @override
  State<ShaderControls> createState() => _ShaderControlsState();
}

class _ShaderControlsState extends State<ShaderControls> {
  @override
  Widget build(BuildContext context) {
    final sp = widget.model.shaderParams;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sp.shaderName),
          SliderParam(
            label: sp.fftSmoothing.label,
            min: sp.fftSmoothing.min,
            max: sp.fftSmoothing.max,
            value: sp.fftSmoothing.value,
            onChanged: (value) {
              widget.model.updateShaderParams(fftSmoothing: value);
              setState(() {});
            },
          ),
          RangeSliderParam(
            label: sp.bins.label,
            min: sp.bins.min,
            max: sp.bins.max,
            values: RangeValues(
              sp.bins.minValue,
              sp.bins.maxValue,
            ),
            onChanged: (value) {
              widget.model.updateShaderParams(
                minBinIndex: value.start.toInt(),
                maxBinIndex: value.end.toInt(),
              );
              setState(() {});
            },
          ),

          for (var i = 0; i < (sp.params?.length ?? 0); i++)
            SliderParam(
              label: sp.params![i].label,
              min: sp.params![i].min,
              max: sp.params![i].max,
              value: sp.params![i].value,
              onChanged: (value) {
                List<ShaderParam> newParams = sp.params!;
                newParams[i] = newParams[i].copyWith(value: value);
                widget.model.updateShaderParams(
                  params: newParams,
                );
                setState(() {});
              },
            ),

          for (var i=0; i<(sp.paramsRange?.length ?? 0); i++)
            RangeSliderParam(
              label: sp.paramsRange![i].label,
              min: sp.paramsRange![i].min,
              max: sp.paramsRange![i].max,
              values: RangeValues(
                sp.paramsRange![i].minValue,
                sp.paramsRange![i].maxValue,
              ),
              onChanged: (value) {
                List<ShaderParamRange> newParams = sp.paramsRange!;
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
