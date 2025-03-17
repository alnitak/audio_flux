// ignore_for_file: public_member_api_docs

import 'package:example/controls/sliders.dart';
import 'package:example/model/model.dart';
import 'package:flutter/material.dart';

/// Common controls for all painters and shaders
class CommonControls extends StatefulWidget {
  const CommonControls({
    required this.model,
    super.key,
  });

  final AudioVisualizerModel model;

  @override
  State<CommonControls> createState() => _CommonControlsState();
}

class _CommonControlsState extends State<CommonControls> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SliderParam(
            label: 'audioScale',
            min: 0.1,
            max: 10,
            value: widget.model.modelParams.audioScale,
            onChanged: (value) {
              widget.model.updateModelParams(audioScale: value);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
